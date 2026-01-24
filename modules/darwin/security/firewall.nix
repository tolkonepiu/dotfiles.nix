{
  networking.applicationFirewall = {
    enable = true; # Turn on macOS application firewall
    blockAllIncoming = false; # Allow inbound responses to outgoing traffic and services you explicitly permit

    allowSignedApp = false; # Do not auto-allow built-in/OS-signed apps that are already installed
    allowSigned = true; # Auto-allow apps signed by a valid certificate when they ask for incoming connections

    enableStealthMode = true; # Drop ICMP ping/port scan probes (no reply to unsolicited traffic)
  };
}
