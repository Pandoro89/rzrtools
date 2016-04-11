class UpdateLetsEncryptJob < Resque::Job
  @queue = :high

  def self.perform
    yml_config = YAML.load_file("#{Rails.root}/config/letsencrypt_plugin.yml") || {}
    cert_generator = LetsencryptPlugin::CertGenerator.new(yml_config.to_h)
    cert_generator.generate_certificate
  end
end