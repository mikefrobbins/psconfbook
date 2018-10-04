$Uri = 'https://expired.badssl.com/'
Invoke-WebRequest -Uri $Uri -SkipCertificateCheck