#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require select2
#= require select2_locale_zh-CN
#= require dataTables/jquery.dataTables
#= require dataTables/extras/dataTables.select
#= require dataTables/bootstrap/3/jquery.dataTables.bootstrap

$.fn.extend
  removeOptions: (removeAll = false) ->
    selector = if removeAll then "option" else "option:not(:first-child)"
    @find(selector).remove()

  appendOptions: (values) ->
    return unless values
    for value in values
      @append("<option value=\"#{value[1]}\">#{value[0]}</option>")

$.extend true, $.fn.dataTable.defaults,
  language:
    emptyTable: "表中数据为空"
    info: "从 _START_ 到 _END_ /共 _TOTAL_ 条数据"
    infoEmpty: "没有数据"
    infoFiltered: "(从 _MAX_ 条数据中检索)"
    lengthMenu: "每页显示 _MENU_ 条记录"
    zeroRecords: "没有检索到数据"
    search: "搜索："
    paginate:
      first: "首页"
      previous: "前一页"
      next: "后一页"
      last: "尾页"

$(document).on "ready page:load page:restore", ->
  $('.select2').select2
    theme: 'bootstrap'
    language: 'zh-CN'

  window.dataTable = $(".table.data-tables:not(.dataTable)").DataTable
    order: [] # Do not sort by default
    pagingType: 'full_numbers'

$(document).on 'page:before-unload', ->
  dataTable.destroy() if dataTable
  clearInterval(interval) if interval?
