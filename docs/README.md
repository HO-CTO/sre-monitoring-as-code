# Documentation-as-code

## Background

The documentation is available to view online [here][tbc].

The repo contains a basic skeleton directory structure created by Middleman App with minimal customisation of index.html.erb in /source. It can be built to local static website files, or run in preview by Middleman server.

## Technical Documentation

This project uses the [Tech Docs Template][template], which is a [Middleman template][mmt] that you can use to build technical documentation using a GOV.UK style.

You’re welcome to use the template even if your service isn’t considered part of GOV.UK, but your site or service must not:

- identify itself as being part of GOV.UK
- use the crown or GOV.UK logotype in the header
- use the GDS Transport typeface
- suggest that it’s an official UK government website if it’s not

👉 To find out more about setting up and managing content for a website using this template, see the [Tech Docs Template documentation][tdt-docs].

## Before you start

To use the Tech Docs Template you need the applications listed below, however you can bypass by running Docker Compose process below:

- [Ruby][install-ruby]
- [Middleman][install-middleman]

## Making changes

To make changes to the documentation for the Tech Docs Template website, edit files in the `source` folder of this repository.

You can add content by editing the `.html.md.erb` files. These files support content in:

- Markdown
- HTML
- Ruby

👉 You can use Markdown and HTML to [generate different content types][example-content] and [Ruby partials to manage content][partials].

👉 Learn more about [producing more complex page structures][multipage] for your website.

## Preview and build your changes locally in Docker (preferred)

Instead of building and running locally and having to install the required dependencies, you can instead run this in Docker.

Run the following command to start the container detached mode: 

```
docker-compose up -d
```

Run the following command to start the containers in non detached mode: 

```
docker-compose up
```
This will display the logs output web url
```
http://localhost:4567
```


To make changes update the required files and restart the container with:

```
docker-compose restart
```

## Preview your changes locally (without Docker)

To preview your new website locally, navigate to your project folder and run:

```sh
bundle exec middleman server
```

👉 See the generated website on `http://localhost:4567` in your browser. Any content changes you make to your website will be updated in real time.

To shut down the Middleman instance running on your machine, use `ctrl+C`.

If you make changes to the `config/tech-docs.yml` configuration file, you need to restart Middleman to see the changes.

## Build (without Docker)

To build the HTML pages from content in your `source` folder, run:

```
bundle exec middleman build
```

Every time you run this command, the `build` folder gets generated from scratch. This means any changes to the `build` folder that are not part of the build command will get overwritten.

## Troubleshooting

Run `bundle update` to make sure you're using the most recent Ruby gem versions.

Run `bundle exec middleman build --verbose` to get detailed error messages to help with finding the problem.

## Diagrams

Diagrams are maintained in [DrawIO](https://app.diagrams.net) using the file [monitoring_as_code.drawio](https://github.com/HO-CTO/sre-monitoring-as-code/blob/main/docs/monitoring_as_code.drawio). 
Once landing in DrawIO web interface select `Save diagrams to: Device > Open Existing Diagram` and select [monitoring_as_code.drawio](https://github.com/HO-CTO/sre-monitoring-as-code/blob/main/docs/monitoring_as_code.drawio) from you're local repository. 
Edit and add new diagrams as you see fit. Files should be numbered and referenced in the docs-as-code markdown as follows: -

```
![Image descriptor](../images/monitoring_as_code-{reference to drawio tab number eg. 1}.png)
```

'.drawio' file is version controlled the same as any other engineering artefact. We use the [drawio-export-action](https://github.com/rlespinasse/drawio-export-action) to render the diagrams as png files from the DrawIO xml.

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
[mmt]: https://middlemanapp.com/advanced/project_templates/
[tdt-docs]: https://tdt-documentation.london.cloudapps.digital
[config]: https://tdt-documentation.london.cloudapps.digital/configuration-options.html#configuration-options
[frontmatter]: https://tdt-documentation.london.cloudapps.digital/frontmatter.html#frontmatter
[multipage]: https://tdt-documentation.london.cloudapps.digital/multipage.html#build-a-multipage-site
[example-content]: https://tdt-documentation.london.cloudapps.digital/content.html#content-examples
[partials]: https://tdt-documentation.london.cloudapps.digital/single_page.html#add-partial-lines
[install-ruby]: https://tdt-documentation.london.cloudapps.digital/install_macs.html#install-ruby
[install-middleman]: https://tdt-documentation.london.cloudapps.digital/install_macs.html#install-middleman
[gem]: https://github.com/alphagov/tech-docs-gem
[template]: https://github.com/alphagov/tech-docs-template
