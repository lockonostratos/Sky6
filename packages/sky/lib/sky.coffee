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
      _id: 0
      display: 'TIỀN MẶT'
    ,
      _id: 1
      display: 'GHI NỢ'
    ]
    @deliveryTypes: [
      _id: 0
      display: 'TRỰC TIẾP'
    ,
      _id: 1
      display: 'GIAO HÀNG'
    ]
    @billDiscounts: [
      _id: false
      display: 'GIẢM GIÁ TÙY CHỌN'
    ,
      _id: true
      display: 'GIẢM GIÁ THEO PHIẾU'
    ]
    @filterDeliveries:[
      _id: 0
      display: 'TẤT CẢ'
    ,
      _id: 1
      display: 'CHƯA NHẬN'
    ,
      _id: 2
      display: 'ĐÃ NHẬN'
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
    @colors: ['green', 'light-green', 'yellow', 'orange', 'blue', 'dark-blue', 'lime', 'pink', 'red', 'purple', 'dark',
              'gray', 'magenta', 'teal', 'turquoise', 'green-sea', 'emeral', 'nephritis', 'peter-river', 'belize-hole',
              'amethyst', 'wisteria', 'wet-asphalt', 'midnight-blue', 'sun-flower', 'carrot', 'pumpkin', 'alizarin',
              'pomegranate', 'clouds', 'sky', 'silver', 'concrete', 'asbestos']
    @randomColor: => @colors[Math.floor(Math.random() * @colors.length)]
@Sky = Sky