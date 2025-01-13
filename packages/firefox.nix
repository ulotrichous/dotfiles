{
  wrapFirefox,
  firefox-esr-unwrapped,
  passff-host,
}:

wrapFirefox firefox-esr-unwrapped {
  nativeMessagingHosts = [ passff-host ];

  # https://mozilla.github.io/policy-templates/
  extraPolicies = {
    OfferToSaveLogins = false;
    ExtensionSettings = {
      "*" = {
        installation_mode = "blocked";
      };

      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi";
      };

      "passff@invicem.pro" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/passff@invicem.pro/latest.xpi";
      };
    };
  };
}
