angular.module('angular-onbeforeunload').directive 'onbeforeunload', [
  '$window'
  '$filter'
  ($window, $filter) ->

    handleOnbeforeUnload = ->
      i = undefined
      form = undefined
      isDirty = false
      i = 0
      while i < forms.length
        form = forms[i]
        if form.scope[form.name].$dirty
          isDirty = true
          break
        i++
      if isDirty
        unloadtext
      else
        undefined

    'use strict'
    unloadtext = undefined
    forms = []
    ($scope, $element) ->
      if $element[0].localName != 'form'
        throw new Error('onbeforeunload directive must only be set on a angularjs form!')
      forms.push
        'name': $element[0].name
        'scope': $scope
      $window.onbeforeunload = handleOnbeforeUnload
      try
        unloadtext = $filter('translate')('onbeforeunload')
      catch err
        unloadtext = ''
      return
]
