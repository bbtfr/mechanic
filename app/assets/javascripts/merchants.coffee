#= require admin
#= require bootstrap/transition
#= require bootstrap/tooltip
#= require bootstrap/popover
#= require Chart
#= require Chart.Scatter
#= require tinymce-jquery

$(document).on "ready page:load page:restore", ->
  $('[data-toggle="popover"]').popover
    viewport:
      selector: 'body'
      padding: 30

  $('.tinymce').tinymce
    height: 300
    setup: window.tinymceSetup,
    content_style: 'body { font-size: 14px!important; }',
    plugins: 'autolink link textcolor image media lists table colorpicker'
    menubar: false
    toolbar: [
      'undo redo | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image table'
      'styleselect bold italic underline strikethrough | forecolor backcolor'
    ]
    table_class_list: [
      title: 'Default'
      value: ''
    ,
      title: 'Bootstrap'
      value: 'table table-hover'
    ]

$(document).on 'page:before-unload', ->
  tinymce.remove()
