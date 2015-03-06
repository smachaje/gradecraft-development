@gradecraft.controller 'GradeCtrl', ['$scope', 'GradePrototype', '$http', ($scope, GradePrototype, $http) -> 

  $scope.init = (params)->
    $scope.grade = new GradePrototype(params.grade)

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
      alert("change!")

    update: ()->
      alert("blur!!")
      if this.hasChanges
        self = this
        $http.put("/grades/#{self.id}/async_update.json", self).success(
          (data,status)->
            self.resetChanges()
        )
        .error((err)->
          alert("update failed!")
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
