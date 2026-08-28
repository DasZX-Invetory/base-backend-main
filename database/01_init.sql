-- ============================================================================
-- SQL INICIAL DO TEMPLATE (PostgreSQL 16+)
-- Objetivo: fornecer base generica para autenticacao + multi-tenant
-- ============================================================================

-- Extensao para UUID
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Tenants (As Empresas que contratam o SaaS)
CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    document VARCHAR(20) NOT NULL, -- CNPJ
    email_contact VARCHAR(255) NOT NULL,
    plan_type VARCHAR(50) DEFAULT 'free', -- free, pro, enterprise
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users (Usuários do Sistema - owner, admin, technician e user)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500), -- URL da imagem de perfil do usuário
    birth_date DATE, -- Data de nascimento do usuário
    role VARCHAR(50) DEFAULT 'technician', -- 'owner', 'manager', 'technician'
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP, -- Soft Delete

    -- Garante que o email seja único DENTRO da empresa, mas pode repetir em empresas diferentes
    UNIQUE(tenant_id, email)
);

-- 3. employees (Funcionários responsaveis pelos equipamentos)
CREATE TABLE IF NOT EXISTS employees (
	id SERIAL PRIMARY KEY,
	tenant_id UUID NOT NULL REFERENCES tenants(id),
	name VARCHAR(255) NOT NULL,
	document VARCHAR(20), -- CPF
	phone VARCHAR(20),
	email VARCHAR(100),
	note TEXT,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP -- Soft Delete
);

-- 4. Inventory classifications (Classificação do inventário)
CREATE TABLE IF NOT EXISTS inventory_classifications (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description TEXT
);

-- 5. Inventory (Inventário)
CREATE TABLE IF NOT EXISTS inventory (
	id SERIAL PRIMARY KEY,
	tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
	name VARCHAR(255) NOT NULL, -- Ex: PC-ADM-01
	classification_id INT NOT NULL REFERENCES inventory_classifications(id),
	employee_id INT REFERENCES employees(id) ON DELETE SET NULL, -- Quem está usando
	brand VARCHAR(100), -- Marca: Dell, Samsung, Cisco
	model VARCHAR(100), -- Modelo: Latitude 5420, Galaxy s22
	serial_number VARCHAR(100), -- Número de série do fabricante.
	patrimony_tag VARCHAR(100), -- O código que vai gerar o QR Code
	status VARCHAR(50) DEFAULT 'active', -- active, maintenance, broken, retired
	location VARCHAR(100), -- Local físico (Ex: Administrativo, Rack 01)
	specific_attributes JSONB, -- Adicionar os atributos de cada componente
	description TEXT, -- Adicionar alguma observação
	purchase_date DATE, -- Data de compra
	warranty_expires_at DATE, -- Data de expiração da garantia
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	deleted_at TIMESTAMP -- Soft Delete
);

-- 6. Inventory Attachments (Fotos e Manuais salvos no MinIO)
CREATE TABLE IF NOT EXISTS inventory_attachments (
	id SERIAL PRIMARY KEY,
	tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
	inventory_id INT NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
	uploaded_by INT REFERENCES users(id) ON DELETE SET NULL, -- Quem fez o upload
	file_name VARCHAR(255) NOT NULL, -- Ex: nota_fiscal_dell.pdf
	file_path TEXT NOT NULL, -- O caminho gerado no MinIO
	file_type VARCHAR(50), -- Tipo do arquivo, Ex: image/png, application/pdf
	is_cover_photo BOOLEAN DEFAULT FALSE, -- Para definir qual foto aparece de capa

	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_tenant ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_employees_tenant ON employees(tenant_id);
CREATE INDEX IF NOT EXISTS idx_employees_name ON employees(name);
CREATE INDEX IF NOT EXISTS idx_employees_doc ON employees(document);

CREATE INDEX IF NOT EXISTS idx_inventory_tenant ON inventory(tenant_id);

CREATE INDEX IF NOT EXISTS idx_attachments_inventory ON inventory_attachments(inventory_id);