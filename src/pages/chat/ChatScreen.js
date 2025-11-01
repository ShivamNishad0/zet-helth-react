import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  Container,
  Box,
  Typography,
  TextField,
  Button,
  Paper,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  Toolbar,
  Avatar,
  Chip,
  IconButton,
} from '@mui/material';
import {
  Send,
  AttachFile,
  Person,
  AccessTime,
} from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { websocketService } from '../../services/websocket';
import Header from '../../components/common/Header';



const ChatScreen = () => {

  const { user, isAuthenticated } = useSelector((state) => state.auth);

  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [onlineUsers, setOnlineUsers] = useState([]);
  const [selectedChat, setSelectedChat] = useState(null);
  const [chats, setChats] = useState([]);
  const messagesEndRef = useRef(null);

  const handleConnected = useCallback((data) => {
    console.log('Connected to chat server');
    // Request chat list
    websocketService.send({ type: 'get_chat_list' });
  }, []);

  const handleMessage = useCallback((data) => {
    if (data.chat_id === selectedChat?.id) {
      setMessages(prev => [...prev, {
        id: Date.now(),
        sender: data.sender,
        message: data.message,
        timestamp: new Date(data.timestamp),
        type: data.message_type || 'text'
      }]);
    }
  }, [selectedChat?.id]);

  const handleTyping = useCallback((data) => {
    if (data.chat_id === selectedChat?.id) {
      setIsTyping(data.is_typing);
    }
  }, [selectedChat?.id]);

  useEffect(() => {
    if (isAuthenticated && user) {
      // Connect to WebSocket
      websocketService.connect(user.id || user.userMobile);

      // Set up event listeners
      websocketService.on('connected', handleConnected);
      websocketService.on('message', handleMessage);
      websocketService.on('typing', handleTyping);
      websocketService.on('user_online', handleUserOnline);
      websocketService.on('user_offline', handleUserOffline);
      websocketService.on('chat_list', handleChatList);
      websocketService.on('error', handleError);

      // Start heartbeat
      websocketService.startHeartbeat();

      return () => {
        websocketService.stopHeartbeat();
        websocketService.disconnect();
      };
    }
  }, [isAuthenticated, user, handleConnected, handleMessage, handleTyping]);





  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleUserOnline = (data) => {
    setOnlineUsers(prev => [...prev.filter(u => u.id !== data.user.id), data.user]);
  };

  const handleUserOffline = (data) => {
    setOnlineUsers(prev => prev.filter(u => u.id !== data.user.id));
  };

  const handleChatList = (data) => {
    setChats(data.chats || []);
  };

  const handleError = (error) => {
    console.error('WebSocket error:', error);
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const handleSendMessage = () => {
    if (!newMessage.trim() || !selectedChat) return;

    websocketService.sendMessage(selectedChat.id, newMessage.trim());
    setNewMessage('');
  };

  const handleTypingStart = () => {
    if (selectedChat) {
      websocketService.sendTyping(selectedChat.id, true);
    }
  };

  const handleTypingStop = () => {
    if (selectedChat) {
      websocketService.sendTyping(selectedChat.id, false);
    }
  };

  const handleChatSelect = (chat) => {
    setSelectedChat(chat);
    setMessages([]);
    websocketService.joinChat(chat.id);

    // Load chat messages (you might want to implement this in the API)
    // loadChatMessages(chat.id);
  };

  const formatTime = (date) => {
    return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  if (!isAuthenticated) {
    return (
      <Container maxWidth="md" sx={{ py: 4 }}>
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="text.secondary">
            Please login to access chat
          </Typography>
        </Paper>
      </Container>
    );
  }

  return (
    <Box sx={{ display: 'flex' }}>
      <Header />

      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />

        <Container maxWidth="lg" sx={{ height: 'calc(100vh - 140px)' }}>
          <Box sx={{ display: 'flex', height: '100%', gap: 2 }}>
            {/* Chat List Sidebar */}
            <Paper sx={{ width: 300, p: 2, display: { xs: 'none', md: 'block' } }}>
              <Typography variant="h6" sx={{ mb: 2 }}>
                Chats
              </Typography>
              <List>
                {chats.map((chat) => (
                  <ListItem
                    key={chat.id}
                    button
                    selected={selectedChat?.id === chat.id}
                    onClick={() => handleChatSelect(chat)}
                    sx={{ borderRadius: 1, mb: 1 }}
                  >
                    <ListItemAvatar>
                      <Avatar>
                        <Person />
                      </Avatar>
                    </ListItemAvatar>
                    <ListItemText
                      primary={chat.name || `Chat ${chat.id}`}
                      secondary={chat.lastMessage || 'No messages yet'}
                    />
                    {chat.unreadCount > 0 && (
                      <Chip
                        label={chat.unreadCount}
                        size="small"
                        color="primary"
                      />
                    )}
                  </ListItem>
                ))}
              </List>
            </Paper>

            {/* Chat Area */}
            <Paper sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
              {selectedChat ? (
                <>
                  {/* Chat Header */}
                  <Box sx={{ p: 2, borderBottom: 1, borderColor: 'divider' }}>
                    <Typography variant="h6">
                      {selectedChat.name || `Chat with ${selectedChat.participants?.join(', ')}`}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {onlineUsers.some(u => selectedChat.participants?.includes(u.id)) ? 'Online' : 'Offline'}
                    </Typography>
                  </Box>

                  {/* Messages */}
                  <Box sx={{ flex: 1, overflow: 'auto', p: 2 }}>
                    <List>
                      {messages.map((message) => (
                        <ListItem key={message.id} sx={{ px: 0 }}>
                          <ListItemAvatar>
                            <Avatar sx={{ width: 32, height: 32 }}>
                              <Person />
                            </Avatar>
                          </ListItemAvatar>
                          <ListItemText
                            primary={
                              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                <Typography variant="body1" fontWeight="bold">
                                  {message.sender?.name || 'User'}
                                </Typography>
                                <Typography variant="caption" color="text.secondary">
                                  <AccessTime sx={{ fontSize: 12, mr: 0.5 }} />
                                  {formatTime(message.timestamp)}
                                </Typography>
                              </Box>
                            }
                            secondary={message.message}
                          />
                        </ListItem>
                      ))}
                      {isTyping && (
                        <ListItem sx={{ px: 0 }}>
                          <Typography variant="body2" color="text.secondary" sx={{ fontStyle: 'italic' }}>
                            Someone is typing...
                          </Typography>
                        </ListItem>
                      )}
                    </List>
                    <div ref={messagesEndRef} />
                  </Box>

                  {/* Message Input */}
                  <Box sx={{ p: 2, borderTop: 1, borderColor: 'divider' }}>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      <TextField
                        fullWidth
                        placeholder="Type a message..."
                        value={newMessage}
                        onChange={(e) => setNewMessage(e.target.value)}
                        onKeyPress={(e) => {
                          if (e.key === 'Enter') {
                            handleSendMessage();
                          }
                        }}
                        onFocus={handleTypingStart}
                        onBlur={handleTypingStop}
                        variant="outlined"
                        size="small"
                      />
                      <IconButton color="primary">
                        <AttachFile />
                      </IconButton>
                      <Button
                        variant="contained"
                        endIcon={<Send />}
                        onClick={handleSendMessage}
                        disabled={!newMessage.trim()}
                      >
                        Send
                      </Button>
                    </Box>
                  </Box>
                </>
              ) : (
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
                      Select a chat to start messaging
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Choose from the chat list or start a new conversation
                    </Typography>
                  </Box>
                </Box>
              )}
            </Paper>
          </Box>
        </Container>
      </Box>
    </Box>
  );
};

export default ChatScreen;
