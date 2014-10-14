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

      taskShow:               { group: 'scrum',     key: 'scrumShow',           description: 'xem task' }
      createTask:             { group: 'scrum',     key: 'scrumShow',           description: 'tạo task' }
      taskManagement:         { group: 'scrum',     key: 'scrumShow',           description: 'q.lý task' }

    @taskStatuses:
      deleted:                {key: 'deleted'}
      wait:                   {key: 'wait'}
      selected:               {key: 'selected'}
      working:                {key: 'working'}
      confirming:             {key: 'confirming'}
      done:                   {key: 'done'}
      rejected:               {key: 'rejected'}
      remaking:               {key: 'remaking'}
      frozen:                 {key: 'frozen'}


    @deliveryStatuses:
      wait:                   {key: 'wait'}
      selected:               {key: 'selected'}
      done:                   {key: 'done'}


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
    ]
    @billDiscounts: [
      _id: false
      display: 'GIẢM GIÁ TÙY CHỌN'
    ,
      _id: true
      display: 'GIẢM GIÁ THEO PHIẾU'
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
      display: 'a'
    ,
      _id: 2
      display: 'b'
    ,
      _id: 3
      display: 'c'
    ,
      _id: 4
      display: 'd'
    ,
      _id: 5
      display: 'e'
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
    @shortName: (fullName, maxlength = 6) ->
      return undefined if !fullName
      splited = fullName?.split(' ')
      name = splited[splited.length - 1]
      middle = splited[splited.length - 2]?.substring(0,1) if name.length < maxlength
      "#{if middle then middle + '.' else ''} #{name}"
    @respectName: (fullName, gender) -> "#{if gender then 'Anh' else 'Chị'} #{fullName.split(' ').pop()}"

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

    @reArrangeLayout: ->
      newHeight = $(window).height() - $("#header").outerHeight() - $("#footer").outerHeight() - 6
      $("#container").css('height', newHeight)

    @animateUsing: (selector, animationType) ->
      $element = $(selector)
      $element.removeClass()
      .addClass("animated #{animationType}")
      .one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $element.removeClass())

    @formatDate: (format = 0, dateObj = new Date())->
      curr_Day   = dateObj.getDate()
      curr_Month = dateObj.getMonth()+1
      curr_Tear  = dateObj.getFullYear().toString()
      if curr_Day < 10 then curr_Day = "0#{curr_Day}"
      if curr_Month < 10 then curr_Month = "0#{curr_Month}"
      switch format
        when 0 then "#{curr_Day}#{curr_Month}#{curr_Tear.substring(2,4)}"
        when 1 then "#{curr_Day}-#{curr_Month}-#{curr_Tear}"

    @defaultSort: (option = 0)->
      switch option
        when 0 then {sort: {'version.updateAt': -1, 'version.createdAt': -1}}
        when 1 then {sort: {'version.createdAt': -1, 'version.updateAt': -1}}



@Sky = Sky

generateRandomIndex = -> Math.floor(Math.random() * Sky.helpers.monoColors.length)