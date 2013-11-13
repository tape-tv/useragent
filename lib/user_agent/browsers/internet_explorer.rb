class UserAgent
  module Browsers
    class InternetExplorer < Base
      def self.extend?(agent)
        return false unless agent.application && agent.application.comment
        comment = agent.application.comment
        (comment[0] == "compatible" && comment[1] =~ /MSIE/) || # <= IE10
        (comment[0] =~ /Windows NT/ && comment[3] =~ /rv:[\d\.]+/) # >= IE11+
      end

      def browser
        "Internet Explorer"
      end

      def version
        version_str = if old_ie?
                        application.comment[1].sub("MSIE ", "")
                      else
                        application.comment[3].sub("rv:", "")
                      end
        Version.new(version_str)
      end

      def compatibility_view?
        version == "7.0" && application.comment.detect { |c| c['Trident/'] }
      end

      # Before version 4.0, Chrome Frame declared itself (unversioned) in a comment;
      # as of 4.0 it can declare itself versioned in a comment
      # or as a separate product with a version
      def chromeframe
        cf = application.comment.include?("chromeframe") || detect_product("chromeframe")
        return cf if cf
        cf_comment = application.comment.detect { |c| c['chromeframe/'] }
        cf_comment ? UserAgent.new(*cf_comment.split('/', 2)) : nil
      end

      def platform
        "Windows"
      end

      def os
        os_str = if old_ie?
                   application.comment[2]
                 else
                   application.comment[0]
                 end
        OperatingSystems.normalize_os(os_str)
      end

      private
      def old_ie?()
        application.comment[1] =~ /MSIE/
      end

      def new_ie?()
        !old_ie?
      end
    end
  end
end
