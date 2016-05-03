#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require select2
#= require select2_locale_zh-CN
#= require dataTables/jquery.dataTables
#= require dataTables/bootstrap/3/jquery.dataTables.bootstrap

$.fn.extend
  removeOptions: ->
    @find("option:not(:first-child)").remove()

  appendOptions: (values) ->
    return unless values
    for value in values
      @append("<option value=\"#{value[1]}\">#{value[0]}</option>")

ready = if Turbolinks.supported then 'turbolinks:load' else 'ready'
$(document).on ready, ->
  $('.select2').select2
    theme: 'bootstrap'
    language: 'zh-CN'

  window.dataTable = $(".table.data-tables").DataTable
    order: [] # Do not sort by default
    pagingType: 'full_numbers'
    language:
      lengthMenu: "每页显示 _MENU_ 条记录"
      info: "从 _START_ 到 _END_ /共 _TOTAL_ 条数据"
      infoEmpty: "没有数据"
      infoFiltered: "(从 _MAX_ 条数据中检索)"
      zeroRecords: "没有检索到数据"
      search: "搜索："
      paginate:
        first: "首页"
        previous: "前一页"
        next: "后一页"
        last: "尾页"

$(document).on 'turbolinks:before-render', ->
  dataTable.destroy() if dataTable
  clearInterval(interval) if interval?
