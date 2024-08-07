"use client";

import React, { useState, useEffect, useRef } from 'react';
import axiosInstance from '../api/axiosInstance';
import { Flights } from '../../components/flights';
import { Loading } from '../../components/loading';
import { Weather } from '../../components/weather';

interface ChatProps {
  conversationId: number | null;
}

interface Message {
  id: number;
  content: string;
  user: string | null;
  widget_data: any | null;
}

const Chat: React.FC<ChatProps> = ({ conversationId }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (conversationId) {
      const fetchMessages = async () => {
        try {
          const response = await axiosInstance.get(`/api/v1/conversations/${conversationId}/messages`);
          setMessages(response.data);
        } catch (error) {
          console.error('Error fetching messages:', error);
        }
      };

      fetchMessages();
    }
  }, [conversationId]);

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages]);

  const handleSend = async () => {
    if (input.trim() && conversationId) {
      const userMessage: Message = {
        id: Date.now(), // temporary ID, replace it with the real ID from the backend
        content: input,
        user: 'user',
        widget_data: null
      };
      setMessages([...messages, userMessage]);
      setInput('');
      setIsLoading(true);

      try {
        await axiosInstance.post(`/api/v1/conversations/${conversationId}/messages`, {
          content: input
        });
        // Fetch messages again to get the system response
        const response = await axiosInstance.get(`/api/v1/conversations/${conversationId}/messages`);
        setMessages(response.data);
      } catch (error) {
        console.error('Error sending message:', error);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value);
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleSend();
    }
  };

  return (
    <div className="chat-window">
      <div className="messages">
        {Array.isArray(messages) && messages.filter(message => message.user != 'assistant').map((message) => (
            <div
              key={message.id}
              className={`message ${message.user == 'user' ? 'user-message' : 'system-message'}`}
            >
              {message.widget_data && message.widget_data.get_flight_info ? (
                <>
                <div style={{marginBottom: '20px'}}>{message.content}</div>
                <Flights data={message.widget_data.get_flight_info.flights} />
                </>
              ) : message.widget_data && message.widget_data.get_geo ? (
                `Geo Lookup: ${message.widget_data.get_geo}`
              ) : message.widget_data && message.widget_data.get_weather ? (
                <>
                <div style={{marginBottom: '20px'}}>{message.content}</div>
                <Weather props={message.widget_data.get_weather.weather} />
                </>
              ) : (
                message.content
              )}
            </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      {isLoading && <div className="loading-spinner">Loading...</div>}
      <div className="input-container">
        <input
          type="text"
          value={input}
          onChange={handleInputChange}
          onKeyPress={handleKeyPress}
          placeholder="Type a message"
        />
        <button onClick={handleSend}>Send</button>
      </div>
      <style jsx>{`
        .chat-window {
          display: flex;
          flex-direction: column;
          height: 100%;
          width: 100%;
        }
        .messages {
          flex: 1;
          overflow-y: auto;
          padding: 10px;
          background-color: #f9f9f9;
        }
        .message {
          padding: 10px;
          border-radius: 5px;
          margin-bottom: 10px;
        }
        .user-message {
          background-color: #d1e7dd;
          align-self: flex-end;
        }
        .system-message {
          background-color: aliceblue;
          align-self: flex-start;
        }
        .input-container {
          display: flex;
          padding: 10px;
          background-color: #fff;
          border-top: 1px solid #ccc;
        }
        input {
          flex: 1;
          padding: 10px;
          border: 1px solid #ccc;
          border-radius: 5px;
          margin-right: 10px;
        }
        button {
          padding: 10px 20px;
          background-color: #0070f3;
          color: #fff;
          border: none;
          border-radius: 5px;
          cursor: pointer;
        }
        button:hover {
          background-color: #005bb5;
        }
        .loading-spinner {
          text-align: center;
          padding: 10px;
          font-size: 16px;
          color: #0070f3;
        }
      `}</style>
    </div>
  );
};

export default Chat;
