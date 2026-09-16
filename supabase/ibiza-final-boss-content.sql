-- Fill the empty editorial fields for the existing Ibiza Final Boss record.
-- No permissions, policies or image columns are changed.

update public.memes
set
  meaning = 'A nickname for Jack Kay, whose extremely confident Ibiza club look is framed as the ultimate, overpowered nightclub character — the person you meet at the final level of an Ibiza night out.',
  origin = 'A viral video filmed at Zero Six West in Ibiza in August 2025 showed Newcastle tourist Jack Kay dancing in dark sunglasses, a black vest, a gold chain and a distinctive bowl haircut.',
  example = 'When you reach the last club of the night and the Ibiza Final Boss is waiting at the bar.'
where id = '1789328384070-ibiza_final_boss.jpg';
