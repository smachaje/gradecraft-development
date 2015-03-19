onBeforeUnloadModule = angular.module('on-before-unload', [])

onBeforeUnloadModule.directive 'onBeforeUnload', ->
  (scope, element, attrs) ->
    scope.$on '$locationChangeStart', (event) ->
      alert("prevented!!")
      event.preventDefault()
      return
