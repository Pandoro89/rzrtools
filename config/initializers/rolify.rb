ROLE_ADMIN = "Admin"
ROLE_TROIKA = "Troika"
ROLE_MILITARY_ADVISOR = "Military Advisor"
ROLE_SCOUT_COMMANDER = "Scout Commander"
ROLE_FLEET_COMMANDER = "Fleet Commander"
ROLE_RAZOR_RECON = "Razor Recon"
ROLE_RAZOR_SCOUT = "Razor Scout"
ROLE_RAZOR_MEMBER = "Razor Member"
ROLE_MAKE_PAPS = "PAP Creator"


Rolify.configure do |config|
  # By default ORM adapter is ActiveRecord. uncomment to use mongoid
  # config.use_mongoid

  # Dynamic shortcuts for User class (user.is_admin? like methods). Default is: false
  # config.use_dynamic_shortcuts
end