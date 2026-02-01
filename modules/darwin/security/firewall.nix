{
  networking.applicationFirewall = {
    # Turn on macOS application firewall
    enable = true;
    # Allow inbound responses to outgoing traffic and services you explicitly permit
    blockAllIncoming = false;

    # Do not auto-allow built-in/OS-signed apps that are already installed
    allowSignedApp = false;
    # Auto-allow apps signed by a valid certificate when they ask for incoming connections
    allowSigned = true;

    # Drop ICMP ping/port scan probes (no reply to unsolicited traffic)
    enableStealthMode = true;
  };
}
