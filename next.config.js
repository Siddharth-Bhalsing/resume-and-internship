/** @type {import('next').NextConfig} */
const nextConfig = {
    images: {
        remotePatterns: [
            {
                protocol: 'http',
                hostname: 'localhost',
                port: '',
                pathname: '/**',
            },
            {
                protocol: 'https',
                hostname: 'api.resuchain.gov.in',
                port: '',
                pathname: '/**',
            },
            {
                protocol: 'https',
                hostname: 'images.unsplash.com',
                port: '',
                pathname: '/**',
            },
            {
                protocol: 'https',
                hostname: 'upload.wikimedia.org',
                port: '',
                pathname: '/**',
            },
            {
                protocol: 'https',
                hostname: 'cdn-icons-png.flaticon.com',
                port: '',
                pathname: '/**',
            },
            {
                protocol: 'https',
                hostname: 'cdn.jsdelivr.net',
                port: '',
                pathname: '/**',
            },
        ],
    },
    experimental: {
        serverComponentsExternalPackages: ['pdf-parse', 'mammoth']
    }
}

module.exports = nextConfig