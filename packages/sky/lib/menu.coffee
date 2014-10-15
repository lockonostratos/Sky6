Sky.menu =
  roleManager       : {route: 'roleManager',          display: "PHÂN QUYỀN",         color: ["#2d1219"], icon: "fa-eye-slash"}
  staffManager      : {route: 'staffManager',         display: "TÀI KHOẢN",          color: ["#cbbf82"], icon: "fa-share-alt"}
  customerManager   : {route: 'customerManager',      display: "KHÁCH HÀNG",         color: ["#67917b"], icon: "fa-heart"}
  sales             : {route: 'sales',                display: "BÁN HÀNG",           color: ["#e23258"], icon: "fa-tags"}
  transactionManager: {route: 'transactionManager',   display: "CÔNG NỢ",            color: ["#b7af02"], icon: "fa-credit-card"}
  accountingManager : {route: 'accountingManager',    display: "KẾ TOÁN",            color: ["#b7af02"], icon: "fa-credit-card"}
  returns           : {route: 'returns',              display: "TRẢ HÀNG",           color: ["#cbbf82"], icon: "fa-reply-all"}
  billManager       : {route: 'billManager',          display: "ĐƠN HÀNG",           color: ["#67917b"], icon: "fa-file-text-o"}
  delivery          : {route: 'delivery',             display: "GIAO HÀNG",          color: ["#cbbf82"], icon: "fa-truck"}
  billExport        : {route: 'billExport',           display: "XUẤT KHO",           color: ["#2d1219"], icon: "fa-share-square-o"}
  export            : {route: 'export',               display: "CHUYỂN KHO",         color: ["#"],       icon: "fa-share-square-o"}
  stockManager      : {route: 'stockManager',         display: "XEM TỒN KHO",        color: ["#b7af02"], icon: "fa-eye"}
  import            : {route: 'import',               display: "NHẬP KHO",           color: ["#e23258"], icon: "fa-cubes"}
  inventoryDetail   : {route: 'inventoryDetail',      display: "CHI TIẾT KIỂM KHO",  color: ["#cbbf82"], icon: "fa-eye"}
  inventory         : {route: 'inventory',            display: "KIỂM KHO",           color: ["#2d1219"], icon: "fa-history"}
  report            : {route: 'report',               display: "BÁO CÁO DOANH SỐ",   color: ["#2d1219"], icon: "fa-pie-chart"}
  inventoryReview   : {route: 'inventoryReview',      display: "LỊCH SỬ KIỂM KHO",   color: ["#"],       icon: "fa-tags"}
  inventoryHistory  : {route: 'inventoryHistory',     display: "CHI TIẾT KIỂM KHO",  color: ["#"],       icon: "fa-tags"}
  inventoryIssue    : {route: 'inventoryIssue',       display: "XỬ LÝ MẤT",          color: ["#"],       icon: "fa-wrench"}
  branchManager     : {route: 'branchManager',        display: "CHI NHÁNH",          color: ["#b7af02"], icon: "fa-home"}
  warehouseManager  : {route: 'warehouseManager',     display: "KHO HÀNG",           color: ["#555555"], icon: "fa-building"}
  tracker           : {route: 'tracker',              display: "NHẬT KÝ",            color: ["#"],       icon: "fa-newspaper-o"}
  taskManager       : {route: 'taskManager',          display: "CÔNG VIỆC",          color: ["#"],       icon: "" }

Sky.menuGroup = [
  [Sky.menu.sales, Sky.menu.returns, Sky.menu.billManager]
  [Sky.menu.roleManager, Sky.menu.staffManager, Sky.menu.customerManager]
]

Sky.generateMenuFor = (routeName) ->
  found = false

  for group in Sky.menuGroup
    for menu in group
      if routeName is menu.route
        found = true
        currentGroup = group
        break

    break if found

  Session.set('subMenus', currentGroup) if found