@gradecraft.directive 'commafyInput', ->

  addCommasToInteger = (val) ->
    decimals = `val.indexOf('.') == -1 ? '' : val.replace(/^-?\d+(?=\.)/, '')`
    wholeNumbers = val.replace /(\.\d+)$/, ''
    commas = wholeNumbers.replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'
    "#{commas}#{decimals}"

  {
    scope: {}
    restrict: 'AE'
    replace: false
    template: ''
    link: (scope, elem, attrs, ngModelCtrl) ->

      ngModelCtrl.$parsers.unshift (viewVal) ->
        noCommasVal = viewVal.replace /,/g, ''
        if isValid(noCommasVal) || !noCommasVal
          ngModelCtrl.$setValidity 'commafyInput', true
          return noCommasVal
        else
          ngModelCtrl.$setValidity 'commafyInput', false
          return undefined

      ngModelCtrl.$formatters.push (val) ->
        if options.nullDisplay? && (!val || val == '')
          return options.nullDisplay
        return val if !val? || !isValid val
        ngModelCtrl.$setValidity 'commafyInput', true
        val = addCommasToInteger val.toString()
        if options.prepend?
          val = "#{options.prepend}#{val}"
        if options.append?
          val = "#{val}#{options.append}"
        val

      elem.bind 'keyup', ->
        viewValue = ngModelCtrl.$modelValue
        return if !viewValue? || !isValid(viewValue)
        for formatter in ngModelCtrl.$formatters
          viewValue = formatter(viewValue)
        ngModelCtrl.$viewValue = viewValue
        ngModelCtrl.$render()

      elem.bind 'keydown', ->
        val = elem.val()
        if options.prepend?
          val = val.replace options.prepend, ''
        if options.append?
          val = val.replace options.append, ''
        elem.val val.replace /,/g, '' # ATTN: LINE THAT ADDS ON-CLICK COMMA REMOVAL
        elem[0].select()

      return

  }
