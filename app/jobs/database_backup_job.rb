class DatabaseBackupJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Iniciando Job de Backup Automático..."
    Rake::Task['db:backup'].invoke
  rescue StandardError => e
    Rails.logger.error "Error en DatabaseBackupJob: #{e.message}"
  end
end
