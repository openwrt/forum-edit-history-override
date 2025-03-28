# frozen_string_literal: true

# name: edit-history-override
# about: A super simple plugin to change post edit history privs
# version: 0.0.3
# authors: thess
# url: https://github.com/openwrt/forum-edit-history-override

enabled_site_setting :edit_history_override_enabled

require_dependency 'guardian'
require_dependency 'guardian/post_guardian'

class ::Guardian
end

module ::PostGuardian
  def can_view_edit_history?(post)
    return false unless post

    if !post.hidden
      return true if post.wiki || SiteSetting.edit_history_visible_to_public
    end

    # Logged-in and (staff | override group member | post_owner) and visible
    authenticated? && (is_staff? || 
      (SiteSetting.edit_history_override_enabled && 
        @user.in_any_groups?(SiteSetting.edit_history_override_permitGroups_map)) ||
      @user.id == post.user_id) &&
    can_see_post?(post)
  end
end
