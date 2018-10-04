[System.Net.ServicePointManager]::ServerCertificateValidationCallback =
    [System.Linq.Expressions.Expression]::Lambda(
        [System.Net.Security.RemoteCertificateValidationCallback],
        [System.Linq.Expressions.Expression]::Constant($true),
        [System.Linq.Expressions.ParameterExpression[]](
            [System.Linq.Expressions.Expression]::Parameter(
                [object],
                'sender'
            ),
            [System.Linq.Expressions.Expression]::Parameter(
                [X509Certificate],
                'certificate'
            ),
            [System.Linq.Expressions.Expression]::Parameter(
                [System.Security.Cryptography.X509Certificates.X509Chain],
                'chain'
            ),
            [System.Linq.Expressions.Expression]::Parameter(
                [System.Net.Security.SslPolicyErrors],
                'sslPolicyErrors'
            )
        )
    ).Compile()
$Uri = 'https://expired.badssl.com/'
Invoke-WebRequest -Uri $Uri