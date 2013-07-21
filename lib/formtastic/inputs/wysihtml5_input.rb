module Formtastic
  module Inputs
    class Wysihtml5Input < Formtastic::Inputs::TextInput

      COMMANDS_PRESET = {
        barebone: [ :bold, :italic, :link, :source ],
        basic: [ :bold, :italic, :ul, :ol, :link, :image, :source ],
        all: [  :bold, :italic, :underline, :ul, :ol, :outdent, :indent, :link,
                :image, :source, :center, :left, :right, :undo, :redo ]
      }

      COLORS_PRESET = {
        all: [:black, :silver, :maroon, :fuchsia, :lime, :navy,
              :aqua, :red, :gray, :purple, :green, :olive,
              :yellow, :blue, :teal ],
        basic: [ :black, :red, :yellow, :blue, :green ]
      }

      BLOCKS_PRESET = {
        barebone: [ :p ],
        basic: [ :h3, :h4, :h5, :p ],
        all: [ :h1, :h2, :h3, :h4, :h5, :h6, :p ]
      }

      HEIGHT_PRESET = {
        tiny: 70,
        small: 90,
        medium: 170,
        large: 350,
        huge: 450
      }

      def toolbar_blocks
        blocks = options[:blocks] || input_html_options[:blocks] || :basic
        if !blocks.is_a? Array
          blocks = BLOCKS_PRESET[blocks.to_sym]
        end

        if blocks.any?
          template.content_tag(:li) do
            template.content_tag(:div, class: "editor-command blocks-selector") do
              template.content_tag(:span, I18n.t("wysihtml5.block_style")) <<
              template.content_tag(:ul) do
                blocks.map do |block|
                  template.content_tag(:li) do
                    template.content_tag(
                      :a,
                      I18n.t("wysihtml5.blocks.#{block}", default: block.to_s.titleize),
                      href: "javascript:void(0);",
                      data: {
                        wysihtml5_command: 'formatBlock',
                        wysihtml5_command_value: block
                    })
                  end
                end.join.html_safe
              end
            end
          end
        else
          "".html_safe
        end
      end

      def toolbar_colors
        colors = options[:colors] || input_html_options[:colors] || :all
        if !colors.is_a? Array
          colors = COLORS_PRESET[colors.to_sym]
        end

        if colors.any?
          template.content_tag(:li) do
            template.content_tag(:div, class: "editor-command colors-selector") do
              template.content_tag(:span, I18n.t("wysihtml5.color_style")) <<
              template.content_tag(:ul) do
                colors.map do |color|
                  template.content_tag(:li, :style => "border-right: 5px solid #{color}") do
                    template.content_tag(
                      :a,
                      I18n.t("wysihtml5.colors.#{color}", default: color.to_s.titleize),
                      href: "javascript:void(0);",
                      data: {
                        wysihtml5_command: 'foreColor',
                        wysihtml5_command_value: color
                    })
                  end
                end.join.html_safe
              end
            end
          end
        else
          "".html_safe
        end
      end

      def toolbar_commands
        command_groups = [
          [ :undo, :redo ],
          [ :bold, :italic, :underline ],
          [ :ul, :ol, :outdent, :indent ],
          [ :link ],
          [ :image ],
          [ :source ],
          [ :left, :center, :right ]
        ]
        command_mapper = {
          link: 'createLink',
          image: 'insertImage',
          ul: 'insertUnorderedList',
          ol: 'insertOrderedList',
          source: 'change_view',
          center: 'justifyCenter',
          left: 'justifyLeft',
          right: 'justifyRight'
        }

        toolbar_commands = options[:commands] || input_html_options[:commands] || :basic
        if !toolbar_commands.is_a? Array
          toolbar_commands = COMMANDS_PRESET[toolbar_commands.to_sym]
        end

        command_groups.map do |group|
          commands = ''
          group.each do |command|
            if toolbar_commands.include? command
              wysihtml5_command = command_mapper[command.to_sym] || command.to_s
              title = I18n.t("wysihtml5.command.#{command}", default: command.to_s.titleize)
              commands << template.content_tag(
                :a,
                href: "javascript:void(0)",
                class: "editor-command #{command}",
                title: title,
                data: (command == :source ? {wysihtml5_action: wysihtml5_command} : { wysihtml5_command: wysihtml5_command })
              ) do
                template.content_tag(:span, title)
              end
            end
          end
          if commands.present?
            template.content_tag(:li, commands.html_safe)
          else
            nil
          end
        end.compact.join.html_safe
      end

      def toolbar
        template.content_tag(:ul, id: "#{input_html_options[:id]}-toolbar", class: "toolbar") do
          toolbar_blocks << toolbar_commands
        end << toolbar_dialogs
      end

      def to_html
        height = options[:height] || input_html_options[:height] || :medium

        if !height.is_a? Integer
          height = HEIGHT_PRESET[height.to_sym]
        end

        opts = { style: "height: #{height}px" }

        input_wrapping do
          label_html <<
          template.content_tag(:div, class: 'activeadmin-wysihtml5') do
            toolbar <<
            builder.text_area(method, input_html_options.merge(opts))
          end
        end
      end

      def toolbar_dialogs
        html = <<-HTML
        <div class="activeadmin-wysihtml5-modal modal-link">
          <div class="modal-title">
            #{I18n.t("wysihtml5.dialog.link.dialog_title")}
          </div>
          <div class="modal-content">
            <ul class="tabs">
              <li><a data-tab-handle="1" href="#modal-link-url">#{I18n.t("wysihtml5.dialog.link.url_title")}</a></li>
              <li><a data-tab-handle="1" href="#modal-link-email">#{I18n.t("wysihtml5.dialog.link.email_title")}</a></li>
              <li><a data-tab-handle="1" href="#modal-link-anchor">#{I18n.t("wysihtml5.dialog.link.anchor_title")}</a></li>
            </ul>
            <div data-tab="1" id="modal-link-url">
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.url")}</label>
                <input type="text" name="url" placeholder="http://">
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.text")}</label>
                <input type="text" name="text" placeholder="#{I18n.t("wysihtml5.dialog.link.your_text_here")}">
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.title")}</label>
                <input type="text" name="title">
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.rel")}</label>
                <input type="text" name="rel">
              </div>
              <div class="input boolean">
                <label>
                  <input type="checkbox" name="blank" /> #{I18n.t("wysihtml5.dialog.link.blank")}
                </label>
              </div>
            </div>
            <div data-tab="1" id="modal-link-email">
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.email")}</label>
                <input type="text" name="email" placeholder="your@email.com">
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.text")}</label>
                <input type="text" name="text" placeholder="#{I18n.t("wysihtml5.dialog.link.your_text_here")}">
              </div>
            </div>
            <div data-tab="1" id="modal-link-anchor">
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.anchor")}</label>
                <input type="text" name="anchor" placeholder="anchor-name">
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.link.text")}</label>
                <input type="text" name="text" placeholder="#{I18n.t("wysihtml5.dialog.link.your_text_here")}">
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <a data-modal="close" data-action="cancel" class="button">#{I18n.t("wysihtml5.dialog.cancel")}</a>
            <a data-modal="close" data-action="save" class="button primary">#{I18n.t("wysihtml5.dialog.ok")}</a>
          </div>
        </div>
        <div class="activeadmin-wysihtml5-modal modal-image">
          <div class="modal-title">
            #{I18n.t("wysihtml5.dialog.image.dialog_title")}
          </div>
          <div class="modal-content">
            <ul class="tabs">
              <li><a data-tab-handle="1" href="#modal-image-url">#{I18n.t("wysihtml5.dialog.image.url_title")}</a></li>
              <li><a data-tab-handle="1" href="#modal-image-gallery">#{I18n.t("wysihtml5.dialog.image.gallery_title")}</a></li>
            </ul>
            <div data-tab="1" id="modal-image-url">
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.image.url")}</label>
                <input type="text" name="url" placeholder="http://" />
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.image.alt")}</label>
                <input type="text" name="alt" />
              </div>
              <div class="input string">
                <label>#{I18n.t("wysihtml5.dialog.image.title")}</label>
                <input type="text" name="title" />
              </div>
              <div class="input select">
                <label>#{I18n.t("wysihtml5.dialog.image.alignment")}</label>
                <select name="alignment">
                  <option value="">#{I18n.t("wysihtml5.dialog.image.default")}</option>
                  <option value="wysiwyg-float-left">#{I18n.t("wysihtml5.dialog.image.left")}</option>
                  <option value="wysiwyg-float-right">#{I18n.t("wysihtml5.dialog.image.right")}</option>
                </select>
              </div>
            </div>
            <div data-tab="1" id="modal-image-gallery">
              <div class="assets-container">
                <ul></ul>
              </div>
              <div class="optional-inputs">
                <div class="input string">
                  <label>#{I18n.t("wysihtml5.dialog.image.alt")}</label>
                  <input type="text" name="alt" />
                </div>
                <div class="input string">
                  <label>#{I18n.t("wysihtml5.dialog.image.title")}</label>
                  <input type="text" name="title" />
                </div>
                <div class="input select">
                  <label>#{I18n.t("wysihtml5.dialog.image.alignment")}</label>
                  <select name="alignment">
                    <option value="">default</option>
                    <option value="wysiwyg-float-left">#{I18n.t("wysihtml5.dialog.image.left")}</option>
                    <option value="wysiwyg-float-right">#{I18n.t("wysihtml5.dialog.image.right")}</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <a data-modal="close" data-action="cancel" class="button">#{I18n.t("wysihtml5.dialog.cancel")}</a>
            <a data-modal="close" data-action="save" class="button primary">#{I18n.t("wysihtml5.dialog.ok")}</a>
          </div>
        </div>
        HTML
        html.html_safe
      end

    end
  end
end
