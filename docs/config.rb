require 'govuk_tech_docs'

GovukTechDocs.configure(self)

# Build-specific configuration
configure :build do
  set :build_dir, '../public'
  activate :relative_assets
  set :relative_links, true
end

set :markdown_engine, :kramdown
set :markdown,
    fenced_code_blocks: true,
    tables: true,
    no_intra_emphasis: true