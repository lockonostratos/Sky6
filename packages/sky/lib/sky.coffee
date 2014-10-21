colorGenerateHistory = []

class Sky
  class @global

  class @system
    @merchantPermissions:
      su                    :{group: 'special'     ,key:'su'                   ,description: 'tất cả' }
      permissionManagement  :{group: 'account'     ,key:'permissionManagement' ,description: 'thay đổi phân quyền' }

      sales                 :{group: 'sales'       ,key:'sales'                ,description: 'bán hàng'     }
      returns               :{group: 'sales'       ,key:'returns'              ,description: 'trả hàng'     }
      destroySalesBill      :{group: 'sales'       ,key:'destroySalesBill'     ,description: 'xóa hóa đơn' }

      deliveryCreate        :{group: 'delivery'    ,key:'deliveryCreate'       ,description: 'tạo giao hàng'      }
      deliveryShow          :{group: 'delivery'    ,key:'deliveryShow'         ,description: 'xem giao hàng'      }
      deliveryEdit          :{group: 'delivery'    ,key:'deliveryEdit'         ,description: 'chỉnh giao hàng'    }
      deliveryConfirm       :{group: 'delivery'    ,key:'deliveryConfirm'      ,description: 'xác nhận giao hàng' }
      deliveryDestroy       :{group: 'delivery'    ,key:'deliveryDestroy'      ,description: 'hủy giao hàng'      }
      destroyDelivery       :{group: 'delivery'    ,key:'destroyDelivery'      ,description: 'xóa giao hàng'      }

      returnCreate          :{group: 'returns'    ,key:'returnCreate'          ,description: 'tạo phiếu trả hàng' }
      returnShow            :{group: 'returns'    ,key:'returnShow'            ,description: 'xem trả hàng'       }
      returnEdit            :{group: 'returns'    ,key:'returnEdit'            ,description: 'chỉnh trả hàng'     }
      returnConfirm         :{group: 'returns'    ,key:'returnConfirm'         ,description: 'xác nhận trả hàng'  }
      returnDestroy         :{group: 'returns'    ,key:'returnShow'            ,description: 'hủy trả hàng'       }
      destroyReturn         :{group: 'returns'    ,key:'destroyReturn'         ,description: 'xóa trả hàng'       }

      importShow            :{group: 'import'   ,key:'importShow'           ,description: 'xem nhập kho'     }
      importCreate          :{group: 'import'   ,key:'importCreate'         ,description: 'tạo nhập kho'     }
      importEdit            :{group: 'import'   ,key:'importEdit'           ,description: 'chỉnh nhập kho'   }
      importConfirm         :{group: 'import'   ,key:'importConfirm'        ,description: 'xác nhận nhập kho'}
      importDestroy         :{group: 'import'   ,key:'importDestroy'        ,description: 'hủy nhập kho'     }
      destroyImport         :{group: 'import'   ,key:'destroyImport'        ,description: 'xóa nhập kho'     }

      exportShow            :{group: 'export'   ,key:'exportShow'           ,description: 'xem xuất kho'     }
      exportCreate          :{group: 'export'   ,key:'exportCreate'         ,description: 'tạo xuất kho'     }
      exportEdit            :{group: 'export'   ,key:'exportEdit'           ,description: 'chỉnh xuất kho'   }
      exportConfirm         :{group: 'export'   ,key:'exportConfirm'        ,description: 'xác nhận xuất kho'}
      exportDestroy         :{group: 'export'   ,key:'exportDestroy'        ,description: 'hủy xuất kho'     }
      destroyExport         :{group: 'export'   ,key:'destroyExport'        ,description: 'xóa xuất kho'     }

      inventoryShow         :{group: 'inventory'   ,key:'inventoryShow'        ,description: 'xem kiểm kho'     }
      inventoryCreate       :{group: 'inventory'   ,key:'inventoryCreate'      ,description: 'tạo kiểm kho'     }
      inventoryEdit         :{group: 'inventory'   ,key:'inventoryEdit'        ,description: 'chỉnh kiểm kho'   }
      inventoryConfirm      :{group: 'inventory'   ,key:'inventoryConfirm'     ,description: 'xác nhận kiểm kho'}
      inventoryDestroy      :{group: 'inventory'   ,key:'inventoryDestroy'     ,description: 'hủy kiểm kho'     }
      destroyInventory      :{group: 'inventory'   ,key:'destroyInventory'     ,description: 'xóa kiểm kho'     }


      cashierSale           :{group: 'accounting'  ,key:'cashierSale'          ,description: 'xác nhận thu tiền khi bán hàng' }
      cashierDelivery       :{group: 'accounting'  ,key:'cashierDelivery'      ,description: 'xác nhận thu tiền khi giao hàng thành công' }

      saleExport            :{group: 'warehouse'   ,key:'saleExport'           ,description: 'xuất kho khi bán hàng' }
      importDelivery        :{group: 'warehouse'   ,key:'importDelivery'       ,description: 'xác nhận nhập kho khi giao hàng thất bại' }

      accountManagement     :{group: 'human'       ,key:'accountManagement'   ,description: 'quản lý nhân viên' }

      createCustomer        :{group: 'crm'         ,key:'createCustomer'      ,description: 'tạo khách hàng' }
      customerShow          :{group: 'crm'         ,key:'customerShow'        ,description: 'xem khách hàng' }
      customerManagement    :{group: 'crm'         ,key:'customerManagement'  ,description: 'quản lý khách hàng' }

      transactionShow       :{group: 'finance'     ,key:'transactionShow'       ,description: 'xem thu chi' }
      transactionManagement :{group: 'finance'     ,key:'transactionManagement' ,description: 'q.lý thu chi' }

      taskShow              :{group: 'scrum'       ,key:'scrumShow'           ,description: 'xem task' }
      createTask            :{group: 'scrum'       ,key:'scrumCreate'         ,description: 'tạo task' }
      taskManagement        :{group: 'scrum'       ,key:'scrumManagement '    ,description: 'q.lý task' }

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

    @regEx: (email)->
      reg = /^\w+[\+\.\w-]*@([\w-]+\.)*\w+[\w-]*\.([a-z]{2,4}|\d+)$/i #''
      reg1= /^[0-9A-Za-z]+[0-9A-Za-z_]*@[\w\d.]+.\w{2,4}$/
      reg.test(email)


    @saleStatusIsExport: (sale)->
      if sale.status == sale.received == true and sale.submitted == sale.exported == sale.imported == false and (sale.paymentsDelivery == 0 || sale.paymentsDelivery == 1)
        true
      else
        false

    @saleStatusIsImport: (sale)->
      if sale.status == sale.received == sale.exported == true and sale.submitted == sale.imported == false and sale.paymentsDelivery == 1
        true
      else
        false


@Sky = Sky

generateRandomIndex = -> Math.floor(Math.random() * Sky.helpers.monoColors.length)