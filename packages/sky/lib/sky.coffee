class Sky
  class @global
  class @system
    @merchantPermissions:
      su:                 { key: 'su',                  description: 'tất cả' }
      sales:              { key: 'sales',               description: 'bán hàng' }
      returns:            { key: 'returns',             description: 'trả hàng' }
      detroySalesBill:    { key: 'destroySalesBill',    description: 'xóa hóa đơn' }
      delivery:           { key: 'delivery',            description: 'chuyển hàng' }
      deliveryConfirm:    { key: 'deliveryConfirm',     description: 'xác nhận giao hàng' }
      export:             { key: 'export',              description: 'xuất kho' }
      import:             { key: 'import',              description: 'nhập kho' }
      destroyImport:      { key: 'destroyImport',       description: 'xóa phiếu nhập kho' }

      createCustomer:     { key: 'createCustomer',      description: 'tạo khách hàng' }
      accountManagement:  { key: 'accountManagement',   description: 'quản lý nhân viên' }
      customerManagement: { key: 'customerManagement',  description: 'quản lý khách hàng' }
    @paymentMethods: [
      id: 0
      display: 'TIỀN MẶT'
    ,
      id: 1
      display: 'GHI NỢ'
    ]
    @deliveryTypes: [
      id: 0
      display: 'TRỰC TIẾP'
    ,
      id: 1
      display: 'GIAO HÀNG'
    ]
  class @helpers
    @removeVnSigns: (source) ->
      str = source

      str = str.toLowerCase();
      str = str.replace /à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a"
      str = str.replace /è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e"
      str = str.replace /ì|í|ị|ỉ|ĩ/g, "i"
      str = str.replace /ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o"
      str = str.replace /ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u"
      str = str.replace /ỳ|ý|ỵ|ỷ|ỹ/g, "y"
      str = str.replace /đ/g, "d"

      str = str.replace /!|@|%|\^|\*|\(|\)|\+|\=|\<|\>|\?|\/|,|\.|\:|\;|\'| |\"|\&|\#|\[|\]|~|$|_/g, "-" # tìm và thay thế các kí tự đặc biệt trong chuỗi sang kí tự -
      str = str.replace /-+-/g, "-" #thay thế 2- thành 1-
      str = str.replace /^\-+|\-+$/g, "" #cắt bỏ ký tự - ở đầu và cuối chuỗi
      str

@Sky = Sky