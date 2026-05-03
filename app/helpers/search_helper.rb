module SearchHelper
  def combine_search_fields(fields, keywords, match_type = "cont")
    # Une los campos con _or_ para que Ransack busque en cualquiera de ellos
    # Ejemplo: ['code', 'business_name'] => "code_or_business_name_cont"
    condition_key = fields.map { |f| "#{f}_#{match_type}" }.join('_or_')
    { condition_key => keywords }
  end
end
