class GradeSerializer < ActiveModel::Serializer
  attributes :id, :status, :raw_score, :feedback
end
