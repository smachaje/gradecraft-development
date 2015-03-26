@gradecraft.directive 'onBeforeUnload', ->
  $rootScope.$on '$locationChangeStart', (event) ->
    alert("prevented!!")
    event.preventDefault()
    return
