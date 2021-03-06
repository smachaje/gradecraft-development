class Group < ActiveRecord::Base

  APPROVED_STATUSES = ['Pending', 'Approved', 'Rejected']

  attr_accessible :name, :approved, :assignment_id, :assignment_ids, :student_ids,
    :assignment_groups_attributes, :group_membership_attributes, :text_feedback,
    :proposals_attributes, :proposal, :approved

  attr_reader :student_tokens

  belongs_to :course

  has_many :assignment_groups, :dependent => :destroy
  has_many :assignments, :through => :assignment_groups
  accepts_nested_attributes_for :assignment_groups

  has_many :group_memberships, :dependent => :destroy
  has_many :students, :through => :group_memberships
  accepts_nested_attributes_for :group_memberships

  has_many :grades
  has_many :proposals
  accepts_nested_attributes_for :proposals, allow_destroy: true

  has_many :submissions

  has_many :earned_badges, :as => :group

  before_save :clean_html
  before_validation :cache_associations

  validates_presence_of :name, :approved

  validate :max_group_number_not_exceeded, :min_group_number_met, :unique_assignment_per_group_membership, :assignment_group_present

  scope :approved, -> { where approved: "Approved" }
  scope :rejected, -> { where approved: "Rejected" }
  scope :pending, -> { where approved: "Pending" }

  #Instructors need to approve a group before the group is allowed to proceed
  def approved?
    approved == "Approved"
  end

  def rejected?
    approved == "Rejected"
  end

  #Group submissions
  def submissions_by_assignment_id
    @submissions_by_assignment ||= submissions.group_by(&:assignment_id)
  end

  def submission_for_assignment(assignment)
    submissions_by_assignment_id[assignment.id].try(:first)
  end

  #Badges awarded to a whole group
  #TODO: We've never built a way to award these
  def earned_badges_by_badge_id
    @earned_badges_by_badge ||= earned_badges.group_by(&:badge_id)
  end


  private

  def clean_html
    self.text_proposal = Sanitize.clean(text_proposal, Sanitize::Config::BASIC)
  end


  #Checking to make sure any constraints the instructor has set up around min/max group members are honored
  #TODO verify that the course accepts groups? Otherwise comparison with nil fails
  def min_group_number_met
    if self.students.to_a.count < course.min_group_size
      errors.add :base, "You don't have enough group members."
    end
  end

  def max_group_number_not_exceeded
    if self.students.to_a.count > course.max_group_size
      errors.add :base, "You have too many group members."
    end
  end

  def assignment_group_present
    if self.assignment_groups.to_a.count == 0
      errors.add :base, "You need to check off which #{(course.assignment_term).downcase} your #{(course.group_term).downcase} will work on."
    end
  end

  #We need to make sure students only belong to one group working on a single assignment
  def unique_assignment_per_group_membership
    assignments.each do |a|
      students.each do |s|
        if s.group_for_assignment(a).present? && s.group_for_assignment(a).id != self.id
          errors.add :base, "#{s.name} is already working on this with another #{(course.group_term)}."
        end
      end
    end
  end

  def cache_associations
    # TODO: no method assignment for group!
    self.course_id ||= assignment.try(:course_id)
  end
end
