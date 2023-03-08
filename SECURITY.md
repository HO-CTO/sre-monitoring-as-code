# Security Notice

## What?

This is the security notice for all HomeOffice repositories. The notice explains how vulnerabilities should be reported to HomeOffice. At HomeOffice there are cyber security and information assurance teams, as well as security-conscious people within the programmes, that assess and triage all reported vulnerabilities.

## Reporting a Vulnerability

HomeOffice is an advocate of responsible vulnerability disclosure. If you’ve found a vulnerability, we would like to know so we can fix it. This notice provides details for how you can let us know about vulnerabilities, or alternatively you can view our [security.txt](security.txt) file which contains quick links to contact us.

You can report a vulnerability to GDS through our vulnerability disclosure programme at [HackerOne](https://hackerone.com/<>/embedded_submissions/new). Alternatively, you can send an email to <email goes here>; if you do this you may get a response from <ticketing system>, which is our ticketing system.

When reporting a vulnerability to us, please include:
- the website, page or repository where the vulnerability can be observed
- a brief description of the vulnerability
- details of the steps we need to take to reproduce the vulnerability
- non-destructive exploitation details

If you are able to, please also include:
- the type of vulnerability, for example, the [OWASP category](https://owasp.org/www-community/vulnerabilities/)
- screenshots or logs showing the exploitation of the vulnerability

If you are not sure if the vulnerability is genuine and exploitable, or you have found:
- a non-exploitable vulnerability
- something you think could be improved - for example, missing security headers
- TLS configuration weaknesses - for example weak cipher suite support or the presence of TLS1.0 support

Then you can still [reach out via email](SASSRETeam@digital.homeoffice.gov.uk) or using the [GOV.UK contact form](https://www.gov.uk/contact/govuk).

## Guidelines for reporting a vulnerability
When you are investigating and reporting the vulnerability on a HomeOffice domain or subdomain, you must not:
- break the law
- access unnecessary or excessive amounts of data
- modify data
- use high-intensity invasive or destructive scanning tools to find vulnerabilities
- try a denial of service - for example overwhelming a service on GOV.UK with a high volume of requests
- disrupt GOV.UK’s services or systems
- tell other people about the vulnerability you have found until we have disclosed it
- social engineer, phish or physically attack our staff or infrastructure
- demand money to disclose a vulnerability

Only submit reports about exploitable vulnerabilities through HackerOne.

## Bug bounty
Unfortunately, HomeOffice doesn't offer a paid bug bounty programme. HomeOffice will make efforts to show appreciation to people who take the time and effort to disclose vulnerabilities responsibly. We do have [an acknowledgements page for legitimate issues found by researchers](<acknowledgement-page).

# Code of Conduct

HomeOffice have a contributors code of conduct, which you can find here: [CODE_OF_CONDUCT.md]

---

#### Further reading and inspiration about responsible disclosure and `SECURITY.md`
- <https://www.gov.uk/help/report-vulnerability>
- <https://mojdigital.blog.gov.uk/vulnerability-disclosure-policy/>
- <https://www.ncsc.gov.uk/information/vulnerability-reporting>
- <https://github.com/Trewaters/security-README>

[<disclosure-email-address>]: mailto:<disclosure-email-address>
[CODE_OF_CONDUCT.md]: https://github.com//.github/blob/master/CODE_OF_CONDUCT.md
[OWASP category]: https://www.owasp.org/index.php/Category:OWASP_Top_Ten_2017_Project