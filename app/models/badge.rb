class Badge < ActiveRecord::Base
  attr_accessible :assignment, :assignment_id, :name, :description, :icon,
    :visible, :created_at, :updated_at, :image_file_name, :can_earn_multiple_times,
    :badge_set, :category_id, :value, :multiplier, :badge_set_id, :point_total,
    :earned_badges, :earned_badges_attributes, :score, :badge_files_attributes

  mount_uploader :icon, IconUploader

  has_many :earned_badges, :dependent => :destroy

  has_many :tasks, :as => :taskable, :dependent => :destroy
  belongs_to :course
  #belongs_to :assignment

  belongs_to :badge_set
  accepts_nested_attributes_for :badge_set
  accepts_nested_attributes_for :earned_badges, allow_destroy: true

  has_many :submissions, as: :assignment

  has_many :badge_files, :dependent => :destroy
  accepts_nested_attributes_for :badge_files

  before_validation :cache_associations

  validates_presence_of :course, :name

  scope :ordered, -> { 'assignments.id ASC' }

  def can_earn_multiple_times
    super || false
  end

  #badges per role
  def earned_badges_by_student_id
    @earned_badges_by_student_id ||= earned_badges.group_by { |eb| [eb.student_id] }
  end

  def earned_badge_for_student(student)
    earned_badges_by_student_id[[student.id]].try(:first)
  end

  def grade_scope
    'Individual'
  end

  private

  def cache_associations
    self.course_id ||= badge_set.try(:course_id)
  end
end
