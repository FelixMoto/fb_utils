function bot = returnBot(varargin)
%
% bot = returnBot(varargin)
% returns bot token and chat_id for Telegram bot configurations
%

% get config name
name = string(varargin{:});

switch name
    case 'Name'
        bot.token = 'placeholder TOKEN';
        bot.chat_id = 'placeholder chat id';
        
end

end
