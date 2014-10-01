colorGenerateHistory = []

class Sky
  class @global
  class @system
    @merchantPermissions:
      su:                     { group: 'special',   key: 'su',                  description: 'tất cả' }
      sales:                  { group: 'sales',     key: 'sales',               description: 'bán hàng' }
      returns:                { group: 'sales',     key: 'returns',             description: 'trả hàng' }
      detroySalesBill:        { group: 'sales',     key: 'destroySalesBill',    description: 'xóa hóa đơn' }

      delivery:               { group: 'sales',     key: 'delivery',            description: 'giao hàng' }
      deliveryConfirm:        { group: 'sales',     key: 'deliveryConfirm',     description: 'xác nhận giao hàng' }
      deliveryDestroy:        { group: 'sales',     key: 'deliveryDestroy',     description: 'hủy giao hàng' }

      exportDelivery:         { group: 'sales',     key: 'exportDelivery',      description: 'xác nhận xuất kho giao hàng' }
      importDestroy:          { group: 'sales',     key: 'deliveryDestroy',     description: 'xác nhận nhập kho giao hàng' }
      cashDestroy:            { group: 'sales',     key: 'importDestroy',       description: 'xác nhận thu tiền giap hàng' }

      export:                 { group: 'warehouse', key: 'export',              description: 'xuất kho' }
      exportDestroy:          { group: 'warehouse', key: 'exportDestroy',       description: 'hủy xuất kho' }
      import:                 { group: 'warehouse', key: 'import',              description: 'nhập kho' }
      importDestroy:          { group: 'warehouse', key: 'importDestroy',       description: 'hủy nhập kho' }
      destroyImport:          { group: 'warehouse', key: 'destroyImport',       description: 'xóa phiếu nhập kho' }

      accountManagement:      { group: 'human',     key: 'accountManagement',   description: 'quản lý nhân viên' }
      createCustomer:         { group: 'crm',       key: 'createCustomer',      description: 'tạo khách hàng' }
      customerShow:           { group: 'crm',       key: 'customerShow',        description: 'quản lý khách hàng' }
      customerManagement:     { group: 'crm',       key: 'customerManagement',  description: 'quản lý khách hàng' }

      transactionShow:        { group: 'finance',   key: 'transactionShow',     description: 'xem thu chi' }
      transactionManagement:  { group: 'finance',   key: 'transactionShow',     description: 'q.lý thu chi' }



    @paymentMethods: [
      _id: 0
      display: 'TIỀN MẶT'
    ,
      _id: 1
      display: 'GHI NỢ'
    ]
    @paymentsDeliveries: [
      _id: 0
      display: 'TRỰC TIẾP'
    ,
      _id: 1
      display: 'GIAO HÀNG'
    ,
      _id: 2
      display: 'Mua Ko Lay Hang'
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
      display: 'ĐƠN HÀNG CHƯA ĐƯỢC NHẬN'
    ,
      _id: 1
      display: 'ĐƠN HÀNG CHƯA XUẤT KHO'
    ,
      _id: 2
      display: 'ĐƠN HÀNG ĐÃ XUẤT KHO'
    ,
      _id: 3
      display: 'XÁC NHẬN TRẠNG THÁI'
    ,
      _id: 4
      display: 'XÁC NHẬN ĐÃ NHẬN TIỀN'
    ,
      _id: 5
      display: 'XÁC NHẬN ĐÃ TRẢ HÀNG'
    ,
      _id: 6
      display: 'XÁC NHẬN KẾT THÚC ĐƠN HÀNG'
    ,
      _id: 7
      display: 'ĐƠN HÀNG ĐÃ HOÀN THÀNH'
    ]
    @viewInventories: [
      _id: 0
      display: 'KIỂM KHO'
    ,
      _id: 1
      display: 'LỊCH SỬ KIỂM KHO'
    ,
      _id: 2
      display: 'XỬ LÝ KIỂM KHO'
    ]
    @priorityTasks: [
      _id: 1
      display: 'Mức 1'
    ,
      _id: 2
      display: 'Mức 2'
    ,
      _id: 3
      display: 'Mức 3'
    ,
      _id: 4
      display: 'Mức 4'
    ,
      _id: 5
      display: 'Mức 5'
    ]
    @viewTasks: [
      _id: 1
      display: 'Xem Tất Cả'
    ,
      _id: 2
      display: 'Chưa Nhận'
    ,
      _id: 3
      display: 'Đang Làm'
    ,
      _id: 4
      display: 'Hoàn Thành'

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
    @shortName: (fullName) ->
      return undefined if !fullName
      splited = fullName?.split(' ')
      name = splited[splited.length - 1]
      middle = splited[splited.length - 2]?.substring(0,1) if name.length < 6
      "#{if middle then middle + '.' else ''} #{name}"


    @colors: ['green', 'light-green', 'yellow', 'orange', 'blue', 'dark-blue', 'lime', 'pink', 'red', 'purple', 'dark',
              'gray', 'magenta', 'teal', 'turquoise', 'green-sea', 'emeral', 'nephritis', 'peter-river', 'belize-hole',
              'amethyst', 'wisteria', 'wet-asphalt', 'midnight-blue', 'sun-flower', 'carrot', 'pumpkin', 'alizarin',
              'pomegranate', 'clouds', 'sky', 'silver', 'concrete', 'asbestos']
    @monoColors: ['green', 'light-green', 'yellow', 'orange', 'blue', 'dark-blue', 'lime', 'pink', 'red', 'purple', 'dark',
                  'gray', 'magenta', 'teal', 'turquoise', 'green-sea', 'emeral', 'nephritis', 'peter-river', 'belize-hole',
                  'amethyst', 'wisteria', 'wet-asphalt', 'midnight-blue', 'sun-flower', 'carrot', 'pumpkin', 'alizarin',
                  'pomegranate', 'clouds', 'sky', 'silver', 'concrete', 'asbestos']
    @randomColor: ->
      if colorGenerateHistory.length >= @monoColors.length
        colorGenerateHistory = []

      while true
        randomIndex = generateRandomIndex()
        colorExisted = _.contains(colorGenerateHistory, randomIndex)
        console.log colorGenerateHistory
        break unless colorExisted

      colorGenerateHistory.push randomIndex
      @monoColors[randomIndex]


@Sky = Sky

generateRandomIndex = -> Math.floor(Math.random() * Sky.helpers.monoColors.length)