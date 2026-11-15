/* Read actual CRTC modes without acquiring DRM master or changing DRM state. */
#include <errno.h>
#include <fcntl.h>
#include <glob.h>
#include <stdio.h>
#include <unistd.h>
#include <xf86drm.h>
#include <xf86drmMode.h>

int main(void)
{
    glob_t cards = {0};
    int readable = 0, first = 1, failures = 0;
    glob("/dev/dri/card[0-9]*", 0, NULL, &cards);
    printf("{\"connectors\":[");
    for (size_t i = 0; i < cards.gl_pathc; ++i) {
        int fd = open(cards.gl_pathv[i], O_RDONLY | O_CLOEXEC);
        if (fd < 0) { ++failures; continue; }
        drmModeRes *resources = drmModeGetResources(fd);
        if (!resources) { ++failures; close(fd); continue; }
        ++readable;
        for (int j = 0; j < resources->count_connectors; ++j) {
            drmModeConnector *connector = drmModeGetConnectorCurrent(fd, resources->connectors[j]);
            if (!connector) { ++failures; continue; }
            drmModeEncoder *encoder = connector->encoder_id ? drmModeGetEncoder(fd, connector->encoder_id) : NULL;
            drmModeCrtc *crtc = encoder && encoder->crtc_id ? drmModeGetCrtc(fd, encoder->crtc_id) : NULL;
            if (connector->connection == DRM_MODE_CONNECTED && crtc && crtc->mode_valid) {
                drmModeModeInfo *mode = &crtc->mode;
                double hz = mode->htotal && mode->vtotal ? (double)mode->clock * 1000 / mode->htotal / mode->vtotal : 0;
                if (mode->flags & DRM_MODE_FLAG_INTERLACE) hz *= 2;
                if (mode->flags & DRM_MODE_FLAG_DBLSCAN) hz /= 2;
                if (mode->vscan > 1) hz /= mode->vscan;
                const char *type = drmModeGetConnectorTypeName(connector->connector_type);
                printf("%s{\"name\":\"%s-%u\",\"width\":%u,\"height\":%u,\"hz\":%.3f}",
                       first ? "" : ",", type ? type : "Unknown", connector->connector_type_id,
                       mode->hdisplay, mode->vdisplay, hz);
                first = 0;
            }
            if (crtc) drmModeFreeCrtc(crtc);
            if (encoder) drmModeFreeEncoder(encoder);
            drmModeFreeConnector(connector);
        }
        drmModeFreeResources(resources);
        close(fd);
    }
    printf("],\"errors\":[%s]}\n", !readable ? "\"DRM readback unavailable\"" : failures ? "\"Some DRM devices/connectors unreadable\"" : "");
    globfree(&cards);
    return readable ? 0 : 1;
}
