@gradecraft.provider 'BeforeUnload', ->
  _leavingPageText = 'You\'ll lose your changes if you leave'
  _leavingPageText2 = 'Are you sure you want to leave this page?'
  _turnOffConfirm = false
  _debugCallback = angular.noop

  @development = (config) ->
    _turnOffConfirm = config
    this

  @setLeavingText = (text1, text2) ->
    _leavingPageText = text1
    _leavingPageText2 = text2
    this

  @debugCallback = (callback) ->
    _debugCallback = callback
    this

  @$get = [
    '$window'
    ($window) ->
      { init: (top, bottom) ->
        _leavingPageText = top or _leavingPageText
        _leavingPageText2 = bottom or _leavingPageText2
        if !_turnOffConfirm

          $window.onbeforeunload = (e) ->
            _leavingPageText

        (event, confirmCallback, cancelCallback) ->
          if _turnOffConfirm
            confirmCallback()
            _debugCallback()
            $window.onbeforeunload = null
            return
          if confirm(leavingPageText + '\n\n' + leavingPageText2)
            # OK
            $window.onbeforeunload = null
            callback()
          else
            # Cancel
            event.preventDefault()
            cancelCallback()
          return
        # return func
}
      # end return
  ]
  return

angular.module('angular-beforeunload')
