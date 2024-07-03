/-
# Convergence of sequences

By Judith Ludwig, Christian Merten and Florent Schaffhauser,
Proseminar on computer-assisted mathematics,
Heidelberg, Summer Semester 2024

In this project, we show basic properties of convergent sequences. The goal is to show that the sequence of the `n`-th root of `n` converges to one.
-/

import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-
We can find lemma names by using the library search tactic `exact?`.
-/

example (x y : ℝ) : |x + y| ≤ |x| + |y| := by
  exact abs_add x y

/-
Definition of a convergent sequence `a : ℕ → ℝ`.
-/

def ConvergesTo (a : ℕ → ℝ) (x : ℝ) : Prop :=
  ∀ ε > 0, ∃ (n : ℕ), ∀ m ≥ n, |a m - x| < ε

namespace ConvergesTo

/-
The definition of `ConvergesTo` unwrapped.
-/

lemma iff (a : ℕ → ℝ) (x : ℝ) :
    ConvergesTo a x ↔ ∀ ε > 0, ∃ (n : ℕ), ∀ m ≥ n, |a m - x| < ε := by
  rfl

/-
In the definition of `ConvergesTo`, we may replace the condition `< ε` by `≤ ε`.
-/

lemma iff' (a : ℕ → ℝ) (x : ℝ) :
    ConvergesTo a x ↔ ∀ ε > 0, ∃ (n : ℕ), ∀ m ≥ n, |a m - x| ≤ ε := by
  constructor
  · intro h ε hε
    obtain ⟨n, hn⟩ := h ε hε
    use n
    intro m hmn
    exact le_of_lt (hn m hmn)
  · intro h ε hε
    obtain ⟨n, hn⟩ := h (ε / 2) (by simpa)
    use n
    intro m hmn
    have : |a m - x| ≤ ε / 2 := hn m hmn
    have : ε / 2 < ε := by simpa
    linarith

/-
Constant sequences converge to the constant value.
-/

theorem of_constant (x : ℝ) : ConvergesTo (fun _ ↦ x) x := by
  dsimp [ConvergesTo]
  intro ε hε
  use 0
  intro m _
  simp only [sub_self, abs_zero]
  assumption

/-
The sequence `1 / n` converges to zero. Here is a proof, with only two 'sorry's left to fill.
-/

example : ConvergesTo (fun n ↦ 1 / n) 0 := by
  rw [iff']
  intro ε hε
  use ⌈1/ε⌉₊
  intro m hm
  have hle₁ : (1 / m : ℝ) ≤ (1 / ⌈1 / ε⌉₊ : ℝ) := by
    apply one_div_le_one_div_of_le
    · simpa
    · simpa using hm
  have hle₂ : (1 / ⌈1 / ε⌉₊ : ℝ) ≤ 1 / (1 / ε) := by
    apply one_div_le_one_div_of_le
    · simpa
    · exact Nat.le_ceil (1 / ε)
  calc
    |(1 / m : ℝ) - 0| = (1 / m : ℝ) := by simp
                    _ ≤ (1 / ⌈1 / ε⌉₊ : ℝ) := hle₁
                    _ ≤ 1 / (1 / ε) := hle₂
                    _ = ε := one_div_one_div ε

/-
The sum of two convergent sequences is convergent and the limit is the sum of the limits. There is one `sorry` left to fill, though!
-/

theorem add (a₁ a₂ : ℕ → ℝ) (x₁ x₂ : ℝ) (h₁ : ConvergesTo a₁ x₁)
    (h₂ : ConvergesTo a₂ x₂) : ConvergesTo (a₁ + a₂) (x₁ + x₂) := by
  intro ε hε
  obtain ⟨n₁, hn₁⟩ := h₁ (ε / 2) (by simpa)
  obtain ⟨n₂, hn₂⟩ := h₂ (ε / 2) (by simpa)
  use (max n₁ n₂)
  intro m hmn
  have hlt₁ : |a₁ m - x₁| < ε / 2 := by
    apply hn₁
    exact le_of_max_le_left hmn
  have hlt₂ : |a₂ m - x₂| < ε / 2 := by
    apply hn₂
    exact le_of_max_le_right hmn
  calc
    |a₁ m + a₂ m - (x₁ + x₂)| = |(a₁ m - x₁) + (a₂ m - x₂)| := by abel_nf
                            _ ≤ |a₁ m - x₁| + |a₂ m - x₂| := abs_add _ _
                            _ < ε / 2 + ε / 2 := add_lt_add hlt₁ hlt₂
                            _ = ε := by ring

end ConvergesTo

/-
Definition of a bounded sequence.
-/

def IsBounded (a : ℕ → ℝ) : Prop :=
  ∃ (C : ℝ), ∀ (n : ℕ), |a n| ≤ C

namespace IsBounded

/-
The definition of `IsBounded` unwrapped.
-/

theorem iff (a : ℕ → ℝ) : IsBounded a ↔ ∃ (C : ℝ), ∀ (n : ℕ), |a n| ≤ C := by
  rfl

/-
To show that a sequence is bounded, it suffices to show it is bounded starting
from some `n`.
-/

theorem iff' (a : ℕ → ℝ) : IsBounded a ↔
    ∃ (C : ℝ), ∃ (n : ℕ), ∀ m ≥ n, |a m| ≤ C := by
  constructor
  · intro ⟨C, hC⟩
    use C
    use 0
    intro m _
    exact hC m
  · intro ⟨C, n, hn⟩
    rw [iff]
    let s : Finset ℕ := Finset.range (n + 1)
    use C + s.sup' ⟨0, by simp [s]⟩ (fun k ↦ |a k|)
    intro m
    by_cases h : n ≤ m
    · trans
      · exact hn m h
      · simp only [le_add_iff_nonneg_right, Finset.le_sup'_iff]
        use 0
        simp [s]
    · have hmem : m ∈ s := by simp [s]; omega
      trans
      · exact Finset.le_sup' (fun k ↦ |a k|) hmem
      · have : 0 ≤ C := (abs_nonneg (a n)).trans (hn n (Nat.le_refl n))
        simpa

theorem of_convergesTo (a : ℕ → ℝ) (x : ℝ) (h : ConvergesTo a x) :
    IsBounded a := by
  rw [iff']
  obtain ⟨n, hn⟩ := h 1 Real.zero_lt_one
  use 1 + |x|
  use n
  intro m nm
  calc
    |a m| = |a m - x + x| := by ring_nf
        _ ≤ |a m - x| + |x| := abs_add (a m - x) x
        _ ≤ 1 + |x| := add_le_add_right (le_of_lt (hn m nm)) |x|

end IsBounded

namespace ConvergesTo

/-
The product of converging sequences converges to the product of the limits.

Hint for the proof: use that convergent sequences are bounded!
-/

theorem mul (a₁ a₂ : ℕ → ℝ) (x₁ x₂ : ℝ) (h₁ : ConvergesTo a₁ x₁)
    (h₂ : ConvergesTo a₂ x₂) : ConvergesTo (a₁ * a₂) (x₁ * x₂) := by

    have hb₁ := IsBounded.of_convergesTo a₁ x₁ h₁
    have hb₂ := IsBounded.of_convergesTo a₂ x₂ h₂

    obtain ⟨C₁, hC₁⟩ := hb₁
    obtain ⟨C₂, hC₂⟩ := hb₂

    have hC₁_nonneg : 0 ≤ C₁ := by
      trans
      · exact abs_nonneg (a₁ 0)
      · exact hC₁ 0

    have hC₂_nonneg : 0 ≤ C₂ := by
      trans
      · exact abs_nonneg (a₂ 0)
      · exact hC₂ 0

    have hCmax_nonneg : 0 ≤ (max C₁ C₂) := by
      exact le_max_of_le_left hC₁_nonneg

    intro ε hε

    let K := max C₁ C₂ + ε

    have hεK : (ε / (2 * K)) ≤ ε := by
      simp [K]
      sorry

    have hK_pos : 0 < K := by
      apply lt_of_lt_of_le
      · exact hε
      · exact le_add_of_nonneg_left hCmax_nonneg

    obtain ⟨n₁, hn₁⟩ := h₁ (ε / (2 * K)) (div_pos hε (by linarith))
    obtain ⟨n₂, hn₂⟩ := h₂ (ε / (2 * K)) (div_pos hε (by linarith))

    use (max n₁ n₂)
    intro m hmn

    have hlt₁ : |a₁ m - x₁| <  ε / (2 * K) := by
      apply hn₁
      exact le_of_max_le_left hmn

    have hlt₂ : |a₂ m - x₂| <  ε / (2 * K) := by
      apply hn₂
      exact le_of_max_le_right hmn

    have hlt₁' : |a₁ m| ≤ K := by
      trans
      · exact hC₁ m
      · apply le_trans
        · exact le_max_left C₁ C₂
        · simp [K]; linarith

    have hlt₂' : |x₂| ≤ K := by
      simp[K]
      calc
        |x₂| = |x₂ - a₂ m + a₂ m|       := by ring_nf
           _ ≤ |x₂ - a₂ m| + |a₂ m|     := abs_add _ _
           _ = |a₂ m - x₂| + |a₂ m|     := by simp; apply abs_sub_comm _ _
           _ ≤ ε / (2 * K) + |a₂ m|     := add_le_add_right (le_of_lt hlt₂) (|a₂ m|)
           _ ≤ ε / (2 * K) + C₂         := add_le_add_left (hC₂ m) (ε / (2 * K))
           _ ≤ ε / (2 * K) + max C₁ C₂  := add_le_add_left (le_max_right C₁ C₂) (ε / (2 * K))
           _ ≤ ε + max C₁ C₂            := by simp[K]; linarith
           _ = K                        := by simp[K]; linarith

    calc
      |a₁ m * a₂ m - (x₁ * x₂)| = |(a₁ m * a₂ m) - (a₁ m * x₁) + (a₁ m * x₁) - (x₁ * x₂)| := by ring_nf
                              _ = |a₁ m * (a₂ m - x₂) + (a₁ m - x₁) * x₂| := by ring_nf
                              _ ≤ |a₁ m * (a₂ m - x₂)| + |(a₁ m - x₁) * x₂| := abs_add _ _
                              _ = |a₁ m| * |a₂ m - x₂| + |a₁ m - x₁| * |x₂| := by simp [abs_mul]
                              _ ≤ K * |a₂ m - x₂| + |a₁ m - x₁| * |x₂| := add_le_add (mul_le_mul_of_nonneg_right hlt₁' (abs_nonneg _)) (le_refl _)
                              _ ≤ K * |a₂ m - x₂| + |a₁ m - x₁| * K := add_le_add (le_refl _) (mul_le_mul_of_nonneg_left hlt₂' (abs_nonneg _))
                              _ < K * (ε / (2 * K)) + (ε / (2 * K)) * K := add_lt_add (mul_lt_mul_of_pos_left hlt₂ hK_pos) (mul_lt_mul_of_pos_right hlt₁ hK_pos)
                              _ = ε / 2 + ε / 2 := by field_simp; ring
                              _ = ε := by ring

/-
The sandwich lemma: Given three sequences `a`, `b` and `c` such that
`a n ≤ b n ≤ c n` for all `n : ℕ` and both `a` and `c` converge to `x : ℝ`. Then also
`b` converges to `x`.
-/

theorem sandwich (a b c : ℕ → ℝ) (h : ∃ (n : ℕ), ∀ m ≥ n , a m ≤ b m ∧ b m ≤ c m) (x : ℝ)
    (ha : ConvergesTo a x) (hb : ConvergesTo c x) : ConvergesTo b x := by
  intro ε hε
  obtain ⟨n₁, hn₁⟩ := ha ε hε
  obtain ⟨n₂, hn₂⟩ := hb ε hε
  obtain ⟨n₀, h₀⟩ := h
  let N := n₁ + n₂ + n₀
  use N
  intro m hmn
  have hn₁n : n₁ ≤ N := le_max_left n₁ n₂
  have hn₂n : n₂ ≤ N := le_max_right n₁ n₂

  have hmn₁ : n₁ ≤ m := le_trans hn₁n hmn
  have hmn₂ : n₂ ≤ m := le_trans hn₂n hmn

  have h₁ : |a m - x| < ε := hn₁ m hmn₁
  have h₂ : |c m - x| < ε := hn₂ m hmn₂


  have h₃ : a m ≤ b m := sorry
  have h₄ : b m ≤ c m := sorry

  rw [abs_sub_lt_iff] at h₁ h₂
  rw [abs_sub_lt_iff]
  rcases h₁ with ⟨_, h₁r⟩
  rcases h₂ with ⟨h₂l, _⟩
  constructor
  · linarith
  · linarith
end ConvergesTo


/-
To reference the sandwich lemma, use the term `ConvergesTo.sandwich`, which is a function.
-/

#check @ConvergesTo.sandwich

/-
For convenience, we define the `n`-th root of `x : ℝ`.
-/

noncomputable def Nat.root (n : ℕ) (x : ℝ) : ℝ := Real.rpow x (1 / n)


/-
The `n`-th root of `n` to the power of `n` is `n`.
-/

lemma nthRoot_pow (n : ℕ) (h : n ≥ 1) : (n.root n) ^ n = n := by
--lemma nthRoot_pow (n : ℕ) : (n.root n) ^ n = n := by
  simp [Nat.root]
  convert_to Real.rpow (Real.rpow n (1 / n)) n = n
  · simp
  · simp only [Real.rpow_eq_pow]
    rw [← Real.rpow_mul (Nat.cast_nonneg n)]
    field_simp

noncomputable section

def aux (n : ℕ) : ℝ := n.root n - 1

lemma n_root_n_eq_one_add_aux (n : ℕ) : n.root n = 1 + aux n := by
  simp [aux]

lemma one_add_aux_pow_n_eq_n (n : ℕ) (hn : n ≥ 1) : (1 + aux n) ^ n = n := by
  rw [← n_root_n_eq_one_add_aux]
  rw [nthRoot_pow]
  exact hn

lemma one_le_nrootn (n : ℕ) (h : 1 ≤ n) : 1 ≤ n.root n := by
    have h_pow: n = (n.root n) ^ n := by simp [nthRoot_pow n h]
    have h_1 : (1 : ℕ) ^ n = ((1 : ℕ) : ℝ) := by simp
    have h' := h
    apply Nat.mono_cast (α := ℝ) at h
    rw [← h_1] at h
    rw [h_pow] at h
    rw [pow_le_pow_iff_left] at h
    simp at h
    exact h
    · simp
    · apply Real.rpow_nonneg
      simp
    · exact Nat.not_eq_zero_of_lt h'

lemma zero_le_aux (n : ℕ) (h : 1 ≤ n) : 0 ≤ aux n := by
  simp [aux]
  exact one_le_nrootn n h

example : Real.sqrt 4 = 2 := by
  rw [Real.sqrt_eq_iff_sq_eq]
  ring
  exact zero_le_four
  exact zero_le_two


lemma foo (n : ℕ) : (((n + 1) * n) / 2 : ℕ) = (n + 1: ℝ) * n / 2 := by
  norm_cast
  rw [Nat.cast_div]
  · simp
  · rw [mul_comm]
    have := Nat.even_mul_succ_self n
    rw [even_iff_exists_two_nsmul] at this
    simp at this
    obtain ⟨c, hc⟩ := this
    use c
  · simp

lemma foo' (n : ℕ) (h : 1 ≤ n) : ((n * (n - 1)) / 2 : ℕ) = (n * (n - 1 : ℝ)) / 2 := by
  rw [Nat.cast_div]
  · simp
    rw [Nat.cast_sub]
    simp
    exact h
  · sorry
  · simp

example (n : ℕ) (hn : n ≥ 2) : 1 / (n : ℝ) ≤ 1 / 2 := by
  apply one_div_le_one_div_of_le
  sorry
  sorry

example (n : ℕ) (hn : n ≥ 2) : (aux n + 1) ^ n ≥ (n * (n - 1 : ℝ)) / 2 * (aux n) ^ 2 := by
  rw [add_pow]
  simp
  calc
    _ ≥ aux n ^ 2 * Nat.choose n 2 := by
        show _ ≤ _
        apply Finset.single_le_sum (f := fun k ↦ aux n ^ k * n.choose k)
        · intro i hi
          have h1 : 0 ≤ aux n ^ i := by
            apply pow_nonneg
            apply zero_le_aux
            exact Nat.one_le_of_lt hn
          have h2 : 0 ≤ (n.choose i : ℝ) := by
            simp
          exact Left.mul_nonneg h1 h2
        · simp
          exact Nat.succ_lt_succ hn
    _ = (n * (n - 1 : ℝ)) / 2 * (aux n) ^ 2 := by
      rw [Nat.choose_two_right]
      rw [mul_comm]
      rw [foo']
      exact Nat.one_le_of_lt hn

/-
The sequence of the `n`-th root of `n` converges to `1`.
-/

example : ConvergesTo (fun n ↦ n.root n) 1 := by
  have h₁ (n : ℕ) (h : 1 ≤ n) : 1 ≤ n.root n := by
    have h_pow: n = (n.root n) ^ n := by simp [nthRoot_pow n h]
    have h_1 : (1 : ℕ) ^ n = ((1 : ℕ) : ℝ) := by simp
    have h' := h
    apply Nat.mono_cast (α := ℝ) at h
    rw [← h_1] at h
    rw [h_pow] at h
    rw [pow_le_pow_iff_left] at h
    simp at h
    exact h
    · simp
    · apply Real.rpow_nonneg
      simp
    · exact Nat.not_eq_zero_of_lt h'

  have h₂ (n : ℕ) (h : n ≥ 1) : n.root n ≤ 1 + (2 / (Real.sqrt n)) := by
    let a (n : ℕ) : ℝ := n.root n - 1

    have h₂ (n : ℕ) (a : ℕ → ℝ) (h : n ≥ 1) : n ≥ (n * (n - 1)) * Real.rpow (a n) 2 := by
      calc
        n = (n.root n) ^ n := by simp [nthRoot_pow n h]
        _ = (1 + a n) ^ n := by rw [h₁]; apply h
        _ ≥ (n * (n - 1)) * Real.rpow (a n) 2 := by sorry



  have h₃ : ∃ (n : ℕ), ∀ m ≥ n, 1 ≤ m.root m ∧ m.root m ≤ 1 + (2 / (Real.sqrt m)) := by
    use 1
    intro m hm
    constructor
    · apply h₁ m; exact hm
    · apply h₂ m; exact hm

  have h₄ : ConvergesTo (fun n ↦ 1) 1 := by
    apply ConvergesTo.of_constant

  have h₅ : ConvergesTo (fun n ↦ 1 + (2 / (Real.sqrt n))) 1 := by
    rw[ConvergesTo.iff']
    intro ε hε
    use ⌈4 / ε^2⌉₊
    intro m hm
    have hle₁ : (2 / (Real.sqrt m)) ≤ (2 / (Real.sqrt ⌈4 / ε^2⌉₊)) := by
      apply div_le_div_of_nonneg_left
      · simp
      · simp [Real.sqrt_pos]; field_simp
      · simpa using hm
    have hle₂ : (2 / (Real.sqrt ⌈4 / ε^2⌉₊)) ≤ 2 / (Real.sqrt (4 / ε^2)) := by
      apply div_le_div_of_nonneg_left
      · simp
      · simp [Real.sqrt_pos]; field_simp
      · apply Real.sqrt_le_sqrt (Nat.le_ceil (4 / ε^2))
    have h_abs (n : ℕ) : |2 / (Real.sqrt m)| = 2 / (Real.sqrt m) := by
      apply abs_of_pos
      apply div_pos
      · linarith
      · simp [Real.sqrt_pos];
        calc
          0 < ⌈4 / ε^2⌉₊ := by field_simp
          _ ≤ m := by apply hm
    simp
    have h_sqrt4 : Real.sqrt 4 = 2 := by sorry
    calc
      |2 / (Real.sqrt m)| = 2 / (Real.sqrt m) := by apply h_abs m
                      _ ≤ 2 / (Real.sqrt ⌈4 / ε^2⌉₊) := hle₁
                      _ ≤ 2 / (Real.sqrt (4 / ε^2)) := hle₂
                      _ = 2 / (2 / ε) := by field_simp; simp [mul_comm]; constructor; linarith
                      _ = ε := by field_simp

  exact ConvergesTo.sandwich (fun n ↦ 1) (fun n ↦ n.root n) (fun n ↦ 1 + (2 / (Real.sqrt n))) h₃ 1 h₄ h₅