#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require dataTables/jquery.dataTables
#= require dataTables/jquery.dataTables.bootstrap

$(document).on 'ready page:load', ->
  $(".table.data-tables").dataTable
    sPaginationType: "bs_normal"
    oLanguage:
      sLengthMenu: "每页显示 _MENU_ 条记录"
      sZeroRecords: "抱歉， 没有找到"
      sInfo: "从 _START_ 到 _END_ /共 _TOTAL_ 条数据"
      sInfoEmpty: "没有数据"
      sInfoFiltered: "(从 _MAX_ 条数据中检索)"
      sZeroRecords: "没有检索到数据"
      sSearch: "搜索："
      oPaginate:
        sFirst: "首页"
        sPrevious: "前一页"
        sNext: "后一页"
        sLast: "尾页"

$(document).on 'page:before-unload', ->
  clearInterval(interval) if interval?
