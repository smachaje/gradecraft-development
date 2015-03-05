@gradecraft.factory 'GradePrototype', ->
	class GradePrototype
		constructor: (attrs={})->
		  @id = attrs.id
		  @comments = attrs.comments
