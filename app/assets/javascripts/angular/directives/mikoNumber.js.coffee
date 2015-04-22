mikoNumberModule = angular.module('miko-number', [])

mikoNumberModule.directive 'mikoNumber',
['mikoNumberConfig', (mikoNumberConfig) ->

    defaultOptions = mikoNumberConfig.defaultOptions
    controlKeys = [0,8,13] # 0 = tab, 8 = backspace , 13 = enter

    getOptions = (scope, attrs) ->
        options = angular.copy defaultOptions
        if attrs.mikoNumberOptions?
            for own option, value of scope.$eval(attrs.mikoNumberOptions)
                options[option] = value
        options
    
    isNumber = (val) ->
        !isNaN(parseFloat(val)) && isFinite(val)

    # 44 is ',', 45 is '-', 57 is '9' and 47 is '/'
    isNotDigit = (which) ->
        (which < 44 || which > 57 || which is 47)

    isTooLong = (val, maxDigits) ->
      val >= maxDigits

    isMovementKey = (e) ->
      e.which == 37 || e.which == 39

    isDigit = (which) ->
      (which >= 44 and which <= 57 and which is not 47)

    isNotControlKey = (which) ->
      controlKeys.indexOf(which) == -1

    isControlKey = (which) ->
      controlKeys.indexOf(which) >= 0

    invalidAction = (elem, event, options) ->
      invalidKey(event) or invalidZero(elem, event) or maxDigitsReached(elem, options)

    # invalid actions
    invalidKey = (event) ->
      isNotDigit(event.which) && isNotControlKey(event.which)

    invalidZero = (elem, event) ->
      # entering 0 in the first place
      elem[0].selectionStart == 0 and event.which == 48 

    maxDigitsReached = (elem, options) ->
      elem.val().length >= options.maxDigits

    hasMultipleDecimals = (val) ->
      val? && val.toString().split('.').length > 2

    makeMaxDecimals = (maxDecimals) ->
        if maxDecimals > 0
            regexString = "^-?\\d*\\.?\\d{0,#{maxDecimals}}$"
        else
            regexString = "^-?\\d*$"
        validRegex = new RegExp regexString

        (val) -> validRegex.test val
        
    makeMaxNumber = (maxNumber) ->
        (val, number) -> number <= maxNumber

    makeMinNumber = (minNumber) ->
        (val, number) -> number >= minNumber

    makeMaxDigits = (maxDigits) ->
        validRegex = new RegExp "^-?\\d{0,#{maxDigits}}(\\.\\d*)?$"
        (val) -> validRegex.test val

    makeIsValid = (options) ->
        validations = []
        
        if options.maxDecimals?
            validations.push makeMaxDecimals options.maxDecimals
        if options.max?
            validations.push makeMaxNumber options.max
        if options.min?
            validations.push makeMinNumber options.min
        if options.maxDigits?
            validations.push makeMaxDigits options.maxDigits
            
        (val) ->
            return false unless isNumber val
            return false if hasMultipleDecimals val
            number = Number val
            for i in [0...validations.length]
                return false unless validations[i] val, number
            true
        
    addCommasToInteger = (val) ->
        decimals = `val.indexOf('.') == -1 ? '' : val.replace(/^-?\d+(?=\.)/, '')`
        wholeNumbers = val.replace /(\.\d+)$/, ''
        commas = wholeNumbers.replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'
        "#{commas}#{decimals}"

    numberWithCommas = (integer) ->
      integer.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

    resetCommas = (val) ->
      stripped = val.replace(/,/g, "")
      numberWithCommas(stripped)

    getCursorPosition = (element) ->
      if 'selectionStart' in element
        return element.selectionStart
      else if document.selection
        element.focus()
        sel = document.selection.createRange()
        selLen = document.selection.createRange().text.length
        sel.moveStart 'character', -element.value.length
        return sel.text.length - selLen
      return

    setCursorPosition = (element, caretPos) ->
      if element.createTextRange
        range = element.createTextRange()
        range.move 'character', caretPos
        range.select()
      else
        element.focus()
        if element.selectionStart != undefined
          element.setSelectionRange caretPos, caretPos
      return


    {
        restrict: 'A'
        require: 'ngModel'
        scope:
          true
        link: (scope, elem, attrs, ngModelCtrl) ->
            options = getOptions scope, attrs
            isValid = makeIsValid options

            ngModelCtrl.$parsers.unshift (viewVal) ->
                noCommasVal = viewVal.replace /,/g, ''
                if isValid(noCommasVal) || !noCommasVal
                    ngModelCtrl.$setValidity 'mikoNumber', true
                    return noCommasVal
                else
                    ngModelCtrl.$setValidity 'mikoNumber', false
                    return undefined

            ngModelCtrl.$formatters.push (val) ->
                if options.nullDisplay? && (!val || val == '')
                    return options.nullDisplay
                return val if !val? || !isValid val
                ngModelCtrl.$setValidity 'mikoNumber', true
                val = addCommasToInteger val.toString()
                if options.prepend?
                  val = "#{options.prepend}#{val}"
                if options.append?
                  val = "#{val}#{options.append}"
                val

            elem.on 'keyup', (event) ->
              return if isMovementKey(event)

              if event.which == 8 # backspace is pressed
                if elem.val().length == 4 || elem.val().length == 8 # a new comma is added
                  newCursorPosition = elem[0].selectionStart - 1
                else
                  newCursorPosition = elem[0].selectionStart
              else
                if elem.val().length >= options.maxDigits # maxDigits has been reached
                  newCursorPosition = elem[0].selectionStart
                else
                  if elem.val().length == 4 || elem.val().length == 8 # a new comma is added
                    newCursorPosition = elem[0].selectionStart + 1
                  else
                    if elem[0].selectionStart < elem.val().length # cursor is adding numbers, but is not at the end of the input
                      newCursorPosition = elem[0].selectionStart # otherwise
                    else
                      newCursorPosition = elem[0].selectionStart + 1 # otherwise

              elem.val resetCommas(elem.val()) # reformat the number in place
              elem[0].setSelectionRange(newCursorPosition, newCursorPosition) # set the new cursor position

              triggerUpdate = ()->
                if scope.grade.raw_score != elem.val()
                  scope.grade.customUpdate(elem.val())
                scope.rawScoreUpdating = false

              beginUpdate = ()->
                scope.rawScoreUpdating = true
                setTimeout(triggerUpdate, 1400)

              # not updating unless value is longer than 4 digits including commas
              # still some issues moving the comma after input/delete
              # need to add support for delete/backspace if comma is present
              # need to exclude entry of zeroes in 
              if scope.rawScoreUpdating == false
                beginUpdate() unless elem.val().length >= options.maxDigits

            elem.on 'blur', ->
                viewValue = ngModelCtrl.$modelValue
                return if !viewValue? || !isValid(viewValue)
                for formatter in ngModelCtrl.$formatters
                    viewValue = formatter(viewValue)
                ngModelCtrl.$viewValue = viewValue
                ngModelCtrl.$render()

            elem.on 'focus', ->
                val = elem.val()
                if options.prepend?
                  val = val.replace options.prepend, ''
                if options.append?
                  val = val.replace options.append, ''
                # elem.val val.replace /,/g, '' # ATTN: LINE THAT ADDS ON-CLICK COMMA REMOVAL
                elem[0].select()

            if options.preventInvalidInput == true
              elem.on 'keypress', (e) ->
                if invalidAction(elem, event, options)
                  e.preventDefault()
                  e.stopPropagation()

    }
]

mikoNumberModule.provider 'mikoNumberConfig', ->
  _defaultOptions = {}

  @setDefaultOptions = (defaultOptions) ->
    _defaultOptions = defaultOptions

  @$get = ->
    defaultOptions: _defaultOptions

  return
