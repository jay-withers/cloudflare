# The records made by hand in the dashboard before this repo managed them.
# Delete this file in a later change, once it has applied.
import {
  for_each = {
    "CNAME career"                   = "56fefaf0d35bdc38fed897844ce6f811"
    "CNAME finances"                 = "7c1d762c9b82f807c264f78199e7292d"
    "CNAME health"                   = "d4366f054d83392a31a95a5780659feb"
    "CNAME marketagent"              = "ad871c2f82ea35bdfa6a26d72d4b0e53"
    "CNAME observability"            = "01a42f1e5a06308c0ebd84510a918c6f"
    "CNAME rsend"                    = "554926969184cd53aca2dcded20774e8"
    "CNAME rsend.career"             = "5807de08c9ec2dbe67f09e8369fe5d11"
    "CNAME rsend.finances"           = "8fdb5efe601eaff18cc08d1481f3ed70"
    "CNAME rsend.health"             = "51fc40fba666fe3997151d308a4d52b4"
    "CNAME rsend.send"               = "3aa8c12f7b975e202c7273738be6b709"
    "CNAME send"                     = "fcf5ce20f5228b4226cf0c8df6df58bc"
    "CNAME send.career"              = "44934008e71dd68237b8a3271fb2b1d6"
    "CNAME send.finances"            = "1e297fa2b79e9f0ea31eb87a0ed3b302"
    "CNAME send.health"              = "910d6cef1d0a7bf6fb528855a7e3a9b8"
    "CNAME send.send"                = "edd2ec515bd817e1e09c453bddd378c1"
    "CNAME support"                  = "37e005873bc6bd6e37bcdbea92eaa8b9"
    "TXT asuid.career"               = "189b4a1f016cffe106a88bb848edc7e0"
    "TXT asuid.finances"             = "48454af3fc17ef1c3f806722b3bb0817"
    "TXT asuid.health"               = "c534c16a0a14fb329f3f53bb454ab053"
    "TXT asuid.marketagent"          = "97606f216b1ce4bd1fce3312a862ac6c"
    "TXT asuid.observability"        = "ecc50b5ebb2405361c3ab277b8dd16fb"
    "TXT asuid.support"              = "114ef9518a37295c229ecad014beeaad"
    "TXT resend._domainkey"          = "8833779c2a105456225691e881876322"
    "TXT resend._domainkey.career"   = "813cff709f5da819d3706175ce19dc88"
    "TXT resend._domainkey.finances" = "0966645c4b353f77d7bc1c662caf6577" # gitleaks:allow (a record ID, not a key)
    "TXT resend._domainkey.health"   = "78117fbb20c54bb28c30512a09b64598"
    "TXT resend._domainkey.send"     = "1386049526e11f5fe8285ab397d55e0e"
  }

  to = cloudflare_dns_record.this[each.key]
  id = "${data.cloudflare_zone.this.zone_id}/${each.value}"
}
