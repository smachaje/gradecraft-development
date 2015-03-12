@gradecraft.controller 'GradeCtrl', ['$scope', 'GradePrototype', '$http', ($scope, GradePrototype, $http) -> 


  $scope.init = (params)->
    $scope.grade = new GradePrototype(params.grade)
    gradeId = params.grade.id

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

  GradePrototype = (attrs={})->
    # attributes
    this.id = attrs.id
    this.status = attrs.status
    this.raw_score = attrs.raw_score
    this.feedback = attrs.feedback

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
