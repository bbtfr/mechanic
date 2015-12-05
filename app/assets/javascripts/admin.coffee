#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require dataTables/jquery.dataTables
#= require dataTables/bootstrap/3/jquery.dataTables.bootstrap

$(document).on 'ready page:load', ->
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

$(document).on 'page:before-unload', ->
  clearInterval(interval) if interval?
