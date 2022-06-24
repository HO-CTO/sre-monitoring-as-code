require 'govuk_tech_docs'

GovukTechDocs.configure(self)

activate :relative_assets
set :relative_links, true

set :markdown_engine, :kramdown
set :markdown,
    fenced_code_blocks: true,
    tables: true,
    no_intra_emphasis: true