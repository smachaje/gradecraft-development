@gradecraft.controller 'GradeEditCtrl', ['$scope', '$window', '$http', ($scope, $window, $http)-> 
  $scope.init = ()->
    $scope.header = "snakes"

  $scope.$on('$locationChangeStart', (event)->
    alert("state is changing!!")
    event.preventDefault()
  )
]
