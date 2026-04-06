CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(255),
    active_message_id UUID,
    parent_session_id UUID REFERENCES sessions(session_id),
    forked_from_message_id UUID,
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(session_id) ON DELETE CASCADE,
    parent_id UUID REFERENCES messages(message_id) ON DELETE CASCADE,
    role VARCHAR(50),
    content TEXT,
    model_name VARCHAR(255),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    session_id UUID REFERENCES sessions(session_id) ON DELETE CASCADE,
    message_id UUID REFERENCES messages(message_id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50) CHECK (
        file_type IN ('audio', 'image', 'document')
    ),
    mime_type TEXT,
    file_size BIGINT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
