# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( html5shiv.min.js respond.min.js admin.js admin.css
  datatables/sort_both.png datatables/sort_asc.png datatables/sort_desc.png
  datatables/sort_asc_disabled.png datatables/sort_desc_disabled.png )
