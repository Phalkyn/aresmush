module AresMUSH
  module Bbs
    class BbsReadCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      
      attr_accessor :board_name, :num
      
      def crack!
        cmd.crack_args!( /(?<name>[^\=]+)\/(?<num>.+)/)
        self.board_name = titleize_input(cmd.args.name)
        self.num = trim_input(cmd.args.num)
      end
      
      def required_args
        {
          args: [ self.board_name, self.num ],
          help: 'bbs'
        }
      end
      
      def handle
        if (self.num.downcase == 'u')
          Bbs.with_a_board(self.board_name, client, enactor) do |board|  
            unread = board.unread_posts(enactor)
            if (unread.count == 0)
              client.emit_success t('bbs.no_new_posts')
              return
            end
            
            unread.each do |u|
              Global.dispatcher.queue_command(client, Command.new("bbs #{self.board_name}/#{u.post_index}"))
            end
          end
          return
        end
        
        Bbs.with_a_post(self.board_name, self.num, client, enactor) do |board, post|      

          template = PostTemplate.new(board, post, enactor)
          client.emit template.render

          Bbs.mark_read_for_player(enactor, post)
          client.program[:last_bbs_post] = post
        end
      end      
    end
  end
end