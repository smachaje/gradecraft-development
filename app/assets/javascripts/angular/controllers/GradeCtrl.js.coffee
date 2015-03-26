@gradecraft.controller 'GradeCtrl', ['$scope', 'GradePrototype', '$http', 'beforeUnload', ($scope, beforeUnload, GradePrototype, $http) -> 


  $scope.init = (params)->
    gradeParams = params["grade"]
    $scope.grade = new GradePrototype(gradeParams)
    gradeId = gradeParams.id

    $scope.froalaOptions = {
      inlineMode: false,
      minHeight: 100,
      buttons: [ "bold", "italic", "underline", "strikeThrough", "subscript", "superscript", "fontFamily", "fontSize", "color", "formatBlock", "blockStyle", "inlineStyle", "align", "insertOrderedList", "insertUnorderedList", "outdent", "indent", "selectAll", "createLink", "insertVideo", "table", "undo", "redo", "html", "save", "insertHorizontalRule", "removeFormat" ],

      #Set the save URL.
      saveURL: '/grades/' + gradeId + '/async_update',

      #HTTP request type.
      saveRequestType: 'PUT',

      # Additional save params.
      saveParams: {"save_type": "feedback"}
    }

    # Bind a listener on your current $scope and save reference to it.
    onbeforeunload = $scope.$on('$locationChangeStart', BeforeUnload.init('TOP_MESSAGE', 'BOTTOM_MESSAGE'))
    # In this controller the user will be prompted to
    # confirm their choice before they change their location.
    $scope.submitPage = ()->
      # If you invoking your reference then your listener becomes null.
      onbeforeunload()


  GradePrototype = (attrs={})->
    grade = attrs
    this.id = grade["id"]
    this.status = grade["status"]
    this.raw_score = grade["raw_score"]
    this.feedback = grade["feedback"]

    # manage object state
    this.hasChanges = false

  GradePrototype.prototype = 
    change: ()->
      this.hasChanges = true

    update: ()->
      if this.hasChanges
        self = this
        $http.put("/grades/#{self.id}/async_update", self).success(
          (data,status)->
            self.resetChanges()
        )
        .error((err)->
        )

    unloadUpdate: ()->
      self = this
      $http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
          self.resetChanges()
      )
      .error((err)->
      )

    params: ()->
      {
        id: self.id,
        status: self.status,
        raw_score: this.raw_score,
        feedback: this.feedback
      }
    resetChanges: ()->
      this.hasChanges = false


]
