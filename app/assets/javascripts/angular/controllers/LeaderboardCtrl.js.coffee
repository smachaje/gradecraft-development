@gradecraft.controller 'LeaderboardCtrl', ['$rootScope', '$scope', '$window', '$http', ($rootScope, $scope, $window, $http)-> 
  $scope.init = ()->
    $scope.header = "the leaderboard is alive"

  $rootScope.$on('$locationChangeStart', (event)->
    alert("state is changing!!")
    event.preventDefault()
  )
]
