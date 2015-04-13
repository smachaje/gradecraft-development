'use strict'

angular.module('debounce', []).service('debounce', [
  '$timeout'
  ($timeout) ->
    (func, wait, immediate) ->
      timeout = undefined
      args = undefined
      context = undefined
      result = undefined

      debounce = ->

        ### jshint validthis:true ###

        context = this
        args = arguments

        later = ->
          timeout = null
          if !immediate
            result = func.apply(context, args)
          return

        callNow = immediate and !timeout
        if timeout
          $timeout.cancel timeout
        timeout = $timeout(later, wait)
        if callNow
          result = func.apply(context, args)
        result

      debounce.cancel = ->
        $timeout.cancel timeout
        timeout = null
        return

      debounce
]).directive 'debounce', [
  'debounce'
  '$parse'
  (debounce, $parse) ->
    {
      require: 'ngModel'
      priority: 999
      link: ($scope, $element, $attrs, ngModelController) ->
        debounceDuration = $parse($attrs.debounce)($scope)
        immediate = ! !$parse($attrs.immediate)($scope)
        debouncedValue = undefined
        pass = undefined
        prevRender = ngModelController.$render.bind(ngModelController)
        commitSoon = debounce(((viewValue) ->
          pass = true
          ngModelController.$setViewValue viewValue
          pass = false
          return
        ), parseInt(debounceDuration, 10), immediate)

        ngModelController.$render = ->
          prevRender()
          commitSoon.cancel()
          #we must be first parser for this to work properly,
          #so we have priority 999 so that we unshift into parsers last
          debouncedValue = @$viewValue
          return

        ngModelController.$parsers.unshift (value) ->
          if pass
            debouncedValue = value
            value
          else
            commitSoon ngModelController.$viewValue
            debouncedValue
        return

    }
]

