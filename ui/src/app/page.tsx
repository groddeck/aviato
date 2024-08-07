"use client";

import React, { useEffect, useState } from 'react';
import axiosInstance from './api/axiosInstance';
import Chat from './components/Chat';
import { Banner } from '../components/banner';
import moment from 'moment';

type Conversation = {
  id: number;
  created_at: string;
};

const Home: React.FC = () => {
  const [conversationId, setConversationId] = useState<number | null>(null);
  const [priorConversations, setPriorConversations] = useState<Conversation[]>([]);

  useEffect(() => {
    const startNewConversation = async () => {
      try {
        const response = await axiosInstance.post('/api/v1/conversations', { title: 'New Conversation' });
        setConversationId(response.data.id);
      } catch (error) {
        console.error('Error starting a new conversation:', error);
      }
    };

    startNewConversation();
  }, []);

  useEffect(() => {
    const fetchConversations = async () => {
      const response = await axiosInstance.get('/api/v1/conversations');
      setPriorConversations(response.data || []);
    }

    fetchConversations();
  }, []);

  const handleConversationClick = (id: number) => {
    console.log(`Clicked on conversation ${id}`);
    setConversationId(id);
  };

  return (
    <div className="container">
      <Banner />
      <div className="main">
        <aside className="sidebar">
          <h2>Prior Conversations</h2>
          <ul>
            {priorConversations.map((conversation) => (
              <li key={conversation.id} onClick={() => handleConversationClick(conversation.id)} className="conversation-card">
                {moment(conversation.created_at).format('MMM D - hh:mm:ss A')}
              </li>
            ))}
          </ul>
        </aside>
        <div className="chat-container">
          <Chat conversationId={conversationId} />
        </div>
      </div>
      <style jsx>{`
        .container {
          display: flex;
          flex-direction: column;
          height: 100vh;
          overflow: hidden;
        }
        .header {
          background: #0070f3;
          color: white;
          padding: 20px;
          text-align: center;
          flex-shrink: 0;
        }
        .main {
          display: flex;
          flex: 1;
          overflow: hidden;
        }
        .sidebar {
          width: 250px;
          background: #f1f1f1;
          padding: 20px;
          border-right: 1px solid #ccc;
          overflow-y: auto;
          flex-shrink: 0;
        }
        .chat-container {
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          overflow: hidden;
        }
        ul {
          list-style-type: none;
          padding: 0;
        }
        li {
          background: white;
          padding: 10px;
          margin: 10px 0;
          border-radius: 8px;
          box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
          cursor: pointer;
          transition: background 0.3s, transform 0.3s;
        }
        li:hover {
          background: #0070f3;
          color: white;
          transform: translateY(-2px);
        }
      `}</style>
    </div>
  );
};

export default Home;
